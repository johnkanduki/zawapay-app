import 'package:flutter/material.dart';

import '../../../core/account/account_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/auth_card_scaffold.dart';
import '../../../core/widgets/code_input.dart';
import '../../../core/widgets/top_notice.dart';
import '../../../core/widgets/underlined_link.dart';
import '../../../l10n/app_localizations.dart';

/// "Enter the code": 6-digit code sent by e-mail.
class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({
    super.key,
    required this.email,
    required this.onVerified,
    this.onResend,
  });

  final String email;

  /// Sends the code to the server and goes on (depends on the flow). An
  /// error is shown at the top and the user can try again.
  final Future<void> Function(BuildContext context, String code) onVerified;

  /// "Resend": asks the server for a new code.
  final Future<void> Function()? onResend;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  static const _codeLength = 6;
  String _code = '';
  bool _busy = false;

  Future<void> _verify() async {
    setState(() => _busy = true);
    try {
      await widget.onVerified(context, _code);
    } catch (error) {
      if (mounted) showAccountError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    final resend = widget.onResend;
    if (resend == null || _busy) return;
    final sent = AppLocalizations.of(context).codeResent;
    try {
      await resend();
      if (mounted) showTopNotice(context, sent);
    } catch (error) {
      if (mounted) showAccountError(context, error);
    }
  }

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
          busy: _busy,
          onPressed: _code.length == _codeLength && !_busy ? _verify : null,
        ),
        const SizedBox(height: 22),
        Center(
          child: Text.rich(
            TextSpan(
              style: AppText.body(context),
              children: [
                TextSpan(text: l10n.codeNotReceived),
                linkSpan(l10n.resend, _resend),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
