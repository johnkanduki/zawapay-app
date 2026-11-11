import 'package:flutter/material.dart';

import '../../../core/account/account_error.dart';
import '../../../core/account/zawapay_account.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_card_scaffold.dart';
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
      onSend: (email) async {
        zawapayAccount.lang = Localizations.localeOf(sheetContext).languageCode;
        // Same answer whether the account exists or not.
        await zawapayAccount.startReset(email);
        if (sheetContext.mounted) Navigator.of(sheetContext).pop();
        navigator.push(
          MaterialPageRoute(
            builder: (_) => VerifyCodeScreen(
              email: email,
              onResend: () => zawapayAccount.startReset(email),
              onVerified: (codeContext, code) async {
                final ticket = await zawapayAccount.verifyReset(email, code);
                if (!codeContext.mounted) return;
                Navigator.of(codeContext).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => NewPasswordScreen(resetTicket: ticket),
                  ),
                );
              },
            ),
          ),
        );
      },
    ),
  );
}

class _ForgotPasswordForm extends StatefulWidget {
  const _ForgotPasswordForm({required this.onSend});

  final Future<void> Function(String email) onSend;

  @override
  State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  final _email = TextEditingController();
  bool _busy = false;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

  @override
  void initState() {
    super.initState();
    _email.addListener(() => setState(() {}));
  }

  Future<void> _send() async {
    setState(() => _busy = true);
    try {
      await widget.onSend(_email.text.trim());
    } catch (error) {
      if (mounted) showAccountError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
            busy: _busy,
            onPressed: _emailPattern.hasMatch(_email.text.trim()) && !_busy
                ? _send
                : null,
          ),
        ],
      ),
    );
  }
}
