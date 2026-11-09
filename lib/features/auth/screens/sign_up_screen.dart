import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_card_scaffold.dart';
import '../../../core/widgets/underlined_link.dart';
import '../../../l10n/app_localizations.dart';
import 'sign_in_screen.dart';
import 'sign_up_numbers_screen.dart';

/// Sign-up, step 1: identity, mandatory referral code and password.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _email = TextEditingController();
  bool _termsAccepted = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
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
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.givenName],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: l10n.lastNameLabel,
                hint: l10n.lastNameHint,
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
        AppTextField(
          label: l10n.referralCodeLabel,
          hint: l10n.referralCodeHint,
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 18),
        PasswordField(label: l10n.passwordLabel, hint: l10n.passwordMinHint),
        const SizedBox(height: 18),
        PasswordField(
          label: l10n.confirmPasswordLabel,
          hint: l10n.confirmPasswordHint,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 22),
        _TermsCheckbox(
          accepted: _termsAccepted,
          onChanged: (value) => setState(() => _termsAccepted = value),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: l10n.continueButton,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SignUpNumbersScreen(email: _email.text.trim()),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: Text.rich(
            TextSpan(
              style: AppText.body,
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

    return Row(
      children: [
        GestureDetector(
          onTap: () => onChanged(!accepted),
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: accepted ? AppColors.red : AppColors.white,
              borderRadius: BorderRadius.circular(7),
              border: accepted
                  ? null
                  : Border.all(color: AppColors.grey, width: 1.8),
            ),
            child: accepted
                ? const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.white,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: AppText.body,
              children: [
                TextSpan(text: l10n.acceptPrefix),
                linkSpan(l10n.acceptTerms, () {}),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
