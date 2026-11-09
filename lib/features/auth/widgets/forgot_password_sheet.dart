import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_card_scaffold.dart';
import '../../../core/widgets/underlined_link.dart';
import '../../../l10n/app_localizations.dart';
import '../screens/new_password_screen.dart';
import '../screens/verify_code_screen.dart';

/// "Forgot password" sheet: email → 6-digit code → new password.
Future<void> showForgotPasswordSheet(BuildContext context) {
  final navigator = Navigator.of(context);

  return showAppBottomSheet<void>(
    context,
    showClose: true,
    builder: (sheetContext) => _ForgotPasswordForm(
      onSend: (email) {
        Navigator.of(sheetContext).pop();
        navigator.push(
          MaterialPageRoute(
            builder: (_) => VerifyCodeScreen(
              email: email,
              onVerified: (codeContext) => Navigator.of(codeContext)
                  .pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const NewPasswordScreen(),
                    ),
                  ),
            ),
          ),
        );
      },
    ),
  );
}

class _ForgotPasswordForm extends StatefulWidget {
  const _ForgotPasswordForm({required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: AuthCard(
        title: l10n.forgotPasswordTitle,
        subtitle: l10n.forgotPasswordBody,
        children: [
          AppTextField(
            label: l10n.emailLabel,
            hint: l10n.emailHint,
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 26),
          PrimaryButton(
            label: l10n.sendCode,
            onPressed: () => widget.onSend(_email.text.trim()),
          ),
          const SizedBox(height: 22),
          Center(
            child: Text.rich(
              TextSpan(
                style: AppText.body,
                children: [
                  TextSpan(text: l10n.codeNotReceived),
                  linkSpan(l10n.resend, () {}),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
