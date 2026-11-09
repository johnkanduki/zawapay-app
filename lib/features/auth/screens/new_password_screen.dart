import 'package:flutter/material.dart';

import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_card_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/password_strength.dart';

/// "New password", with the live strength meter and rules.
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  String _password = '';

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
        ),
        const SizedBox(height: 26),
        PrimaryButton(
          label: l10n.save,
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ],
    );
  }
}
