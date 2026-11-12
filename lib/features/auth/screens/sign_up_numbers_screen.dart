import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/account/account_error.dart';
import '../../../core/account/zawapay_account.dart';
import '../../../core/countries/country.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_card_scaffold.dart';
import '../../../core/widgets/phone_number_field.dart';
import '../../../core/widgets/top_notice.dart';
import '../../../l10n/app_localizations.dart';
import '../open_home.dart';
import 'account_created_screen.dart';
import 'profile_photo_screen.dart';
import 'verify_code_screen.dart';

/// Sign-up, step 2: the Mobile Money number.
///
/// - Payment number: receives the USSD payment confirmation requests.
/// - Receiving number: where withdrawals are sent. Same as the payment
///   number by default; a second field appears only if the box is unchecked.
///
/// The withdrawal PIN is not asked here: it will be set at the first withdrawal.
///
/// "Create my account" sends everything to the server: e-mail code, then the
/// membership (sponsor for ever, country, numbers), then the profile photo.
class SignUpNumbersScreen extends StatefulWidget {
  const SignUpNumbersScreen({
    super.key,
    required this.email,
    required this.password,
    required this.sponsor,
    required this.firstName,
    required this.lastName,
    this.signedIn = false,
  });

  /// Already signed in with Google or Apple: no e-mail code, the membership
  /// is created straight away.
  final bool signedIn;

  final String email;
  final String password;

  /// Confirmed sponsor's @, without the "@".
  final String sponsor;
  final String firstName;
  final String lastName;

  @override
  State<SignUpNumbersScreen> createState() => _SignUpNumbersScreenState();
}

class _SignUpNumbersScreenState extends State<SignUpNumbersScreen> {
  bool _sameNumberForWithdrawals = true;
  bool _busy = false;
  final _payment = TextEditingController();
  final _receiving = TextEditingController();
  Country? _paymentCountry;
  Country? _receivingCountry;

  @override
  void dispose() {
    _payment.dispose();
    _receiving.dispose();
    super.dispose();
  }

  Country get _homeCountry =>
      AppSettingsScope.maybeOf(context)?.country ?? supportedCountries.first;

  /// "+243812345678", or null when the field is empty.
  String? _full(TextEditingController field, Country? country) {
    var digits = field.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    // Côte d'Ivoire, Benin, Congo, Gabon: the leading 0 is part of the number.
    if (!keepsLeadingZero.contains((country ?? _homeCountry).isoCode)) {
      digits = digits.replaceFirst(RegExp('^0+'), '');
    }
    return '${(country ?? _homeCountry).dialCode}$digits';
  }

  Future<void> _sendCode() => zawapayAccount.startSignUp(
    email: widget.email,
    password: widget.password,
    firstName: widget.firstName,
    lastName: widget.lastName,
  );

  /// Where withdrawals (and every transfer received) will arrive.
  String? get _receivePhone => _sameNumberForWithdrawals
      ? _full(_payment, _paymentCountry)
      : _full(_receiving, _receivingCountry);

  /// A withdrawal number belongs to one account only: checked before the
  /// e-mail code is sent. True when it is free (or not given).
  Future<bool> _receivePhoneFree() async {
    final phone = _receivePhone;
    if (phone == null) return true;
    final taken = AppLocalizations.of(context).receivePhoneTaken;
    var free = true;
    try {
      free = await zawapayAccount.findByReceivePhone(phone) == null;
    } on AccountException catch (e) {
      if (e.code != 'phone_shared') rethrow;
      free = false;
    }
    if (!free && mounted) {
      showTopNotice(context, taken, icon: Icons.error_rounded);
    }
    return free;
  }

  Future<void> _create() async {
    setState(() => _busy = true);
    zawapayAccount.lang = Localizations.localeOf(context).languageCode;
    try {
      if (!await _receivePhoneFree() || !mounted) return;
      if (widget.signedIn) {
        await _join(context, replace: false);
        return;
      }
      await _sendCode();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyCodeScreen(
            email: widget.email,
            onResend: _sendCode,
            onVerified: (codeContext, code) async {
              await zawapayAccount.verifySignUp(widget.email, code);
              if (codeContext.mounted) await _join(codeContext, replace: true);
            },
          ),
        ),
      );
    } on AccountException catch (error) {
      // This e-mail already has an OMINIMUM account (Sapotti, or a sign-up
      // stopped half-way): same password → it joins Zawapay App directly.
      if (error.code != 'account_exists' || !mounted) {
        if (mounted) showAccountError(context, error);
        return;
      }
      try {
        await zawapayAccount.signIn(widget.email, widget.password);
      } catch (_) {
        if (mounted) showAccountError(context, error);
        return;
      }
      if (mounted) await _join(context, replace: false);
    } catch (error) {
      if (mounted) showAccountError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Membership (once), then the profile photo page.
  Future<void> _join(BuildContext context, {required bool replace}) async {
    final payment = _full(_payment, _paymentCountry);
    final member =
        await zawapayAccount.me() ??
        await zawapayAccount.join(
          sponsor: widget.sponsor,
          country: _homeCountry.isoCode,
          paymentPhone: payment,
          receivePhone: _receivePhone,
          firstName: widget.firstName,
          lastName: widget.lastName,
        );
    if (!context.mounted) return;
    final route = MaterialPageRoute<void>(
      builder: (_) => ProfilePhotoScreen(
        onFinished: (photoContext, photoPath) async {
          await zawapayAccount.uploadPhoto(await File(photoPath).readAsBytes());
          // Google / Apple (no password): straight into the app.
          if (widget.signedIn) {
            final signedIn = await zawapayAccount.remember(
              member,
              photo: photoPath,
            );
            if (photoContext.mounted) openHome(photoContext, signedIn);
            return;
          }
          // By e-mail: "Account created", then the person signs in by
          // themself with their identifier or e-mail and password.
          await zawapayAccount.signOut();
          if (photoContext.mounted) {
            Navigator.of(photoContext).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AccountCreatedScreen()),
              (_) => false,
            );
          }
        },
      ),
    );
    final navigator = Navigator.of(context);
    replace ? navigator.pushReplacement(route) : navigator.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AuthCardScaffold(
      title: l10n.numbersTitle,
      subtitle: l10n.numbersSubtitle,
      children: [
        FieldLabel(l10n.paymentNumberLabel),
        PhoneNumberField(
          controller: _payment,
          onCountryChanged: (c) => _paymentCountry = c,
        ),
        _HelpText(l10n.paymentNumberHelp),
        const SizedBox(height: 22),
        AppCheckbox(
          value: _sameNumberForWithdrawals,
          onChanged: (value) =>
              setState(() => _sameNumberForWithdrawals = value),
          label: Text(
            l10n.sameNumberForWithdrawals,
            style: AppText.body(context),
          ),
        ),
        if (!_sameNumberForWithdrawals) ...[
          const SizedBox(height: 22),
          FieldLabel(l10n.receivingNumberLabel),
          PhoneNumberField(
            controller: _receiving,
            onCountryChanged: (c) => _receivingCountry = c,
          ),
          _HelpText(l10n.receivingNumberHelp),
        ],
        const SizedBox(height: 28),
        PrimaryButton(
          label: l10n.createMyAccount,
          busy: _busy,
          onPressed: _busy ? null : _create,
        ),
      ],
    );
  }
}

class _HelpText extends StatelessWidget {
  const _HelpText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, right: 4),
      child: Text(
        text,
        style: AppText.label(context).copyWith(fontSize: 13, height: 1.4),
      ),
    );
  }
}
