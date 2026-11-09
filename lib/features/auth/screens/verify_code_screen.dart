import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/auth_card_scaffold.dart';
import '../../../core/widgets/code_input.dart';
import '../../../core/widgets/underlined_link.dart';
import '../../../l10n/app_localizations.dart';

/// "Enter the code": 6-digit code sent by e-mail.
class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({
    super.key,
    required this.email,
    required this.onVerified,
  });

  final String email;

  /// What happens once the code is accepted (depends on the flow).
  final void Function(BuildContext context) onVerified;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  static const _codeLength = 6;
  String _code = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AuthCardScaffold(
      title: l10n.enterCodeTitle,
      subtitle: l10n.codeSentTo,
      subtitleTrailing: widget.email.isEmpty ? null : widget.email,
      children: [
        CodeInput(
          length: _codeLength,
          autofocus: true,
          onChanged: (code) => setState(() => _code = code),
        ),
        const SizedBox(height: 26),
        PrimaryButton(
          label: l10n.verify,
          onPressed: _code.length == _codeLength
              ? () => widget.onVerified(context)
              : null,
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
    );
  }
}
