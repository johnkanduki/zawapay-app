import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_card_scaffold.dart';
import '../../../core/widgets/phone_number_field.dart';
import '../../../l10n/app_localizations.dart';
import 'verify_code_screen.dart';

/// Sign-up, step 2: the Mobile Money number.
///
/// - Payment number: receives the USSD payment confirmation requests.
/// - Receiving number: where withdrawals are sent. Same as the payment
///   number by default; a second field appears only if the box is unchecked.
///
/// The withdrawal PIN is not asked here: it will be set at the first withdrawal.
class SignUpNumbersScreen extends StatefulWidget {
  const SignUpNumbersScreen({super.key, required this.email});

  final String email;

  @override
  State<SignUpNumbersScreen> createState() => _SignUpNumbersScreenState();
}

class _SignUpNumbersScreenState extends State<SignUpNumbersScreen> {
  bool _sameNumberForWithdrawals = true;

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
        const SizedBox(height: 22),
        AppCheckbox(
          value: _sameNumberForWithdrawals,
          onChanged: (value) =>
              setState(() => _sameNumberForWithdrawals = value),
          label: Text(l10n.sameNumberForWithdrawals, style: AppText.body),
        ),
        if (!_sameNumberForWithdrawals) ...[
          const SizedBox(height: 22),
          FieldLabel(l10n.receivingNumberLabel),
          const PhoneNumberField(),
          _HelpText(l10n.receivingNumberHelp),
        ],
        const SizedBox(height: 28),
        PrimaryButton(
          label: l10n.createMyAccount,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VerifyCodeScreen(
                email: widget.email,
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
