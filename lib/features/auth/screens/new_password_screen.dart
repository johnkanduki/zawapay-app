import 'package:flutter/material.dart';

import '../../../core/account/account_error.dart';
import '../../../core/account/zawapay_account.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_card_scaffold.dart';
import '../../../core/widgets/top_notice.dart';
import '../../../l10n/app_localizations.dart';
import '../open_home.dart';
import '../widgets/password_strength.dart';

/// "New password", with the live strength meter and rules. Saving signs in
/// and opens the home page.
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key, required this.resetTicket});

  /// Given by the server for the right e-mail code (valid 10 minutes).
  final String resetTicket;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  String _password = '';
  String _confirm = '';
  bool _busy = false;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_confirm != _password) {
      showTopNotice(
        context,
        l10n.passwordsDontMatch,
        icon: Icons.error_rounded,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await zawapayAccount.completeReset(widget.resetTicket, _password);
      if (mounted) await finishSignIn(context);
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
      title: l10n.newPasswordTitle,
      subtitle: l10n.newPasswordBody,
      children: [
        PasswordField(
          label: l10n.newPasswordLabel,
          hint: l10n.passwordMinHint,
          onChanged: (value) => setState(() => _password = value),
        ),
        const SizedBox(height: 18),
        PasswordStrength(password: _password),
        const SizedBox(height: 22),
        PasswordField(
          label: l10n.confirmPasswordLabel,
          hint: l10n.confirmPasswordHint,
          textInputAction: TextInputAction.done,
          onChanged: (value) => setState(() => _confirm = value),
        ),
        const SizedBox(height: 26),
        PrimaryButton(
          label: l10n.save,
          busy: _busy,
          onPressed:
              PasswordRules(_password).passed == 5 &&
                  _confirm.isNotEmpty &&
                  !_busy
              ? _save
              : null,
        ),
      ],
    );
  }
}
