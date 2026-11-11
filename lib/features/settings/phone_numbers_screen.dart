import 'package:flutter/material.dart';

import '../../core/account/account_error.dart';
import '../../core/account/zawapay_account.dart';
import '../../core/countries/country.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_checkbox.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/auth_card_scaffold.dart';
import '../../core/widgets/phone_number_field.dart';
import '../../core/widgets/top_notice.dart';
import '../../l10n/app_localizations.dart';

/// Settings → "Phone numbers": exactly the sign-up numbers page, filled with
/// the current numbers.
///
/// - Payment number: receives the USSD payment requests.
/// - Withdrawal number: where withdrawals AND every transfer received arrive.
///   Same as the payment number while the box stays ticked (the default);
///   unticked, a second field asks for another number. A withdrawal number
///   belongs to one account only.
class PhoneNumbersScreen extends StatefulWidget {
  const PhoneNumbersScreen({
    super.key,
    this.paymentPhone,
    this.receivePhone,
    this.myUsername,
  });

  /// Current numbers, "+243812345678" (null when not given yet).
  final String? paymentPhone;
  final String? receivePhone;

  /// My "@": my own withdrawal number is of course free for me.
  final String? myUsername;

  @override
  State<PhoneNumbersScreen> createState() => _PhoneNumbersScreenState();
}

/// "+243812345678" → (RD Congo, "812345678"); null country when unknown.
(Country?, String) splitPhone(String? full) {
  if (full == null || full.isEmpty) return (null, '');
  final country = supportedCountries
      .where((c) => full.startsWith(c.dialCode))
      .fold<Country?>(
        null,
        (best, c) =>
            best == null || c.dialCode.length > best.dialCode.length ? c : best,
      );
  return (
    country,
    country == null
        ? full.replaceFirst('+', '')
        : full.substring(country.dialCode.length),
  );
}

class _PhoneNumbersScreenState extends State<PhoneNumbersScreen> {
  late final (Country?, String) _pay = splitPhone(widget.paymentPhone);
  late final (Country?, String) _rec = splitPhone(widget.receivePhone);

  /// Ticked by default, and whenever both numbers are the same.
  late bool _same =
      widget.receivePhone == null || widget.receivePhone == widget.paymentPhone;
  late final _payment = TextEditingController(text: _pay.$2);
  late final _receiving = TextEditingController(text: _same ? '' : _rec.$2);
  late Country? _paymentCountry = _pay.$1;
  late Country? _receivingCountry = _same ? null : _rec.$1;
  bool _busy = false;

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
    digits = digits.replaceFirst(RegExp('^0+'), '');
    return '${(country ?? _homeCountry).dialCode}$digits';
  }

  String? get _paymentPhone => _full(_payment, _paymentCountry);
  String? get _receivePhone =>
      _same ? _paymentPhone : _full(_receiving, _receivingCountry);

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      // A withdrawal number belongs to one account only.
      final receive = _receivePhone;
      if (receive != null) {
        var free = true;
        try {
          final owner = await zawapayAccount.findByReceivePhone(receive);
          free = owner == null || owner.handle == widget.myUsername;
        } on AccountException catch (e) {
          if (e.code != 'phone_shared') rethrow;
          free = false;
        }
        if (!free) {
          if (mounted) {
            showTopNotice(
              context,
              l10n.receivePhoneTaken,
              icon: Icons.error_rounded,
            );
          }
          return;
        }
      }
      await zawapayAccount.savePhones(
        paymentPhone: _paymentPhone,
        receivePhone: receive,
      );
      if (!mounted) return;
      showTopNotice(context, l10n.phonesSaved);
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) showAccountError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
          initialCountry: _paymentCountry,
          onCountryChanged: (c) => _paymentCountry = c,
        ),
        _HelpText(l10n.paymentNumberHelp),
        const SizedBox(height: 22),
        AppCheckbox(
          value: _same,
          onChanged: (value) => setState(() => _same = value),
          label: Text(
            l10n.sameNumberForWithdrawals,
            style: AppText.body(context),
          ),
        ),
        if (!_same) ...[
          const SizedBox(height: 22),
          FieldLabel(l10n.receivingNumberLabel),
          PhoneNumberField(
            controller: _receiving,
            initialCountry: _receivingCountry,
            onCountryChanged: (c) => _receivingCountry = c,
          ),
          _HelpText(l10n.receivingNumberHelp),
        ],
        const SizedBox(height: 28),
        PrimaryButton(
          label: l10n.save,
          busy: _busy,
          onPressed: _busy ? null : _save,
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
