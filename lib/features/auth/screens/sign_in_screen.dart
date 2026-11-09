import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_card_scaffold.dart';
import '../../../core/widgets/underlined_link.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/forgot_password_sheet.dart';
import '../widgets/social_logos.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AuthCardScaffold(
      title: l10n.signIn,
      subtitle: l10n.authSubtitle,
      children: [
        AppTextField(
          label: l10n.emailLabel,
          hint: l10n.emailHint,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 18),
        PasswordField(
          label: l10n.passwordLabel,
          hint: l10n.passwordHint,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 26),
        PrimaryButton(label: l10n.signIn, onPressed: () {}),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: l10n.apple,
                bold: false,
                leading: const Icon(
                  Icons.apple,
                  size: 30,
                  color: AppColors.black,
                ),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SecondaryButton(
                label: l10n.google,
                bold: false,
                leading: const GoogleLogo(size: 24),
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Center(
          child: Column(
            children: [
              Text(
                l10n.noAccountYet,
                textAlign: TextAlign.center,
                style: AppText.body,
              ),
              const SizedBox(height: 2),
              UnderlinedLink(
                text: l10n.signUp,
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UnderlinedLink(
              text: l10n.forgotPasswordLink,
              onTap: () => showForgotPasswordSheet(context),
            ),
            UnderlinedLink(
              text: l10n.contactSupportLink,
              textAlign: TextAlign.end,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}
