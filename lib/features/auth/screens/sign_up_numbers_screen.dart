import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_card_scaffold.dart';
import '../../../core/widgets/code_input.dart';
import '../../../core/widgets/phone_number_field.dart';
import '../../../l10n/app_localizations.dart';
import 'verify_code_screen.dart';

/// Sign-up, step 2: Mobile Money numbers and withdrawal PIN.
///
/// - Payment number: receives the USSD payment confirmation requests.
/// - Receiving number: receives the money when the user withdraws.
/// - PIN (4 digits): confirms withdrawals, only inside the app.
class SignUpNumbersScreen extends StatelessWidget {
  const SignUpNumbersScreen({super.key, required this.email});

  final String email;

  static const pinLength = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AuthCardScaffold(
      title: l10n.numbersTitle,
      subtitle: l10n.numbersSubtitle,
      children: [
        FieldLabel(l10n.paymentNumberLabel),
        const PhoneNumberField(),
        _HelpText(l10n.paymentNumberHelp),
        const SizedBox(height: 18),
        FieldLabel(l10n.receivingNumberLabel),
        const PhoneNumberField(),
        _HelpText(l10n.receivingNumberHelp),
        const SizedBox(height: 18),
        FieldLabel(l10n.pinLabel),
        const CodeInput(length: pinLength, obscure: true),
        _HelpText(l10n.pinHelp),
        const SizedBox(height: 18),
        FieldLabel(l10n.confirmPinLabel),
        const CodeInput(length: pinLength, obscure: true),
        const SizedBox(height: 28),
        PrimaryButton(
          label: l10n.createMyAccount,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VerifyCodeScreen(
                email: email,
                onVerified: (codeContext) =>
                    Navigator.of(codeContext)
                        .popUntil((route) => route.isFirst),
              ),
            ),
          ),
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
        style: AppText.label.copyWith(fontSize: 13, height: 1.4),
      ),
    );
  }
}
