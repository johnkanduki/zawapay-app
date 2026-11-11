import 'package:flutter/material.dart';

import '../../../core/account/account_error.dart';
import '../../../core/account/zawapay_account.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_card_scaffold.dart';
import '../../../core/widgets/top_notice.dart';
import '../../../core/widgets/underlined_link.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/password_strength.dart';
import '../widgets/sponsor_invitation_field.dart';
import 'sign_in_screen.dart';
import 'sign_up_numbers_screen.dart';

/// Sign-up, step 1: identity, mandatory sponsor invitation
/// ("Invitation parrain ou marraine") and password.
///
/// "Continue" stays grey until every point is filled in: first name, last
/// name, a valid email, a confirmed sponsor, a password that meets the five
/// rules, and the terms box ticked.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  Sponsor? _sponsor;
  bool _termsAccepted = false;
  bool _checking = false;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

  @override
  void initState() {
    super.initState();
    // Re-check the Continue button on every keystroke.
    for (final controller in [_firstName, _lastName, _email, _password]) {
      controller.addListener(_refresh);
    }
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _firstName.text.trim().isNotEmpty &&
      _lastName.text.trim().isNotEmpty &&
      _emailPattern.hasMatch(_email.text.trim()) &&
      _sponsor != null &&
      PasswordRules(_password.text).passed == 5 &&
      _termsAccepted;

  /// "Continue": an e-mail that is already a member is stopped here with
  /// "Sign in"; otherwise the numbers page opens.
  Future<void> _continue() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final email = _email.text.trim();
    final taken = AppLocalizations.of(context).alreadyMember;
    setState(() => _checking = true);
    try {
      if (await zawapayAccount.isMemberEmail(email)) {
        if (mounted) {
          showTopNotice(context, taken, icon: Icons.info_rounded);
        }
        return;
      }
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SignUpNumbersScreen(
            email: email,
            password: _password.text,
            sponsor: _sponsor!.username,
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
          ),
        ),
      );
    } catch (error) {
      if (mounted) showAccountError(context, error);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AuthCardScaffold(
      title: l10n.signUp,
      subtitle: l10n.authSubtitle,
      children: [
        // First name on the left, last name on the right, to keep the page short.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: l10n.firstNameLabel,
                hint: l10n.firstNameHint,
                controller: _firstName,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.givenName],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: l10n.lastNameLabel,
                hint: l10n.lastNameHint,
                controller: _lastName,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.familyName],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AppTextField(
          label: l10n.emailLabel,
          hint: l10n.emailHint,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 18),
        SponsorInvitationField(
          onConfirmed: (sponsor) => setState(() => _sponsor = sponsor),
        ),
        const SizedBox(height: 18),
        PasswordField(
          label: l10n.passwordLabel,
          hint: l10n.passwordMinHint,
          controller: _password,
          textInputAction: TextInputAction.done,
        ),
        // The five rules appear as soon as the user starts typing.
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _password.text.isEmpty
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: PasswordStrength(password: _password.text),
                ),
        ),
        const SizedBox(height: 22),
        _TermsCheckbox(
          accepted: _termsAccepted,
          onChanged: (value) => setState(() => _termsAccepted = value),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: l10n.continueButton,
          busy: _checking,
          onPressed: _canContinue && !_checking ? _continue : null,
        ),
        const SizedBox(height: 22),
        Center(
          child: Text.rich(
            TextSpan(
              style: AppText.body(context),
              children: [
                TextSpan(text: l10n.alreadyHaveAccount),
                linkSpan(
                  l10n.signIn,
                  () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.accepted, required this.onChanged});

  final bool accepted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppCheckbox(
      value: accepted,
      onChanged: onChanged,
      label: Text.rich(
        TextSpan(
          style: AppText.body(context),
          children: [
            TextSpan(text: l10n.acceptPrefix),
            linkSpan(l10n.acceptTerms, () {}),
          ],
        ),
      ),
    );
  }
}
