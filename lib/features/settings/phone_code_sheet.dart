import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/account/account_error.dart';
import '../../core/account/zawapay_account.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/code_input.dart';
import '../../core/widgets/top_notice.dart';
import '../../core/widgets/underlined_link.dart';
import '../../l10n/app_localizations.dart';

/// The server calls of the WhatsApp / SMS code; tests replace them.
Future<bool> Function(String phone, String channel) sendPhoneCode = (
  phone,
  channel,
) => zawapayAccount.sendPhoneCode(phone, channel: channel);
Future<void> Function(String phone, String code) checkPhoneCode =
    zawapayAccount.checkPhoneCode;

/// A NEW number must be proved: a code is sent to it (SMS, Didit) and typed
/// here. True when proved (or when the SMS check is not active yet).
Future<bool> verifyNewPhone(BuildContext context, String phone) async {
  try {
    // First by WhatsApp (Didit switches to SMS when there is no WhatsApp).
    if (!await sendPhoneCode(phone, 'whatsapp')) return true;
  } catch (error) {
    if (context.mounted) showAccountError(context, error);
    return false;
  }
  if (!context.mounted) return false;
  final ok = await showAppBottomSheet<bool>(
    context,
    showClose: true,
    builder: (_) => _PhoneCodeForm(phone: phone),
  );
  return ok ?? false;
}

class _PhoneCodeForm extends StatefulWidget {
  const _PhoneCodeForm({required this.phone});

  final String phone;

  @override
  State<_PhoneCodeForm> createState() => _PhoneCodeFormState();
}

class _PhoneCodeFormState extends State<_PhoneCodeForm> {
  String _error = '';
  bool _busy = false;
  int _round = 0;

  /// "Send again by SMS" waits a little (the WhatsApp message may arrive).
  static const _wait = 45;
  int _left = _wait;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _left = _wait;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _left--);
      if (_left <= 0) t.cancel();
    });
  }

  /// "+243975135458" → "+243******458".
  String get _masked {
    final p = widget.phone;
    if (p.length < 8) return p;
    return '${p.substring(0, 4)}${'*' * (p.length - 7)}${p.substring(p.length - 3)}';
  }

  Future<void> _onChanged(String code) async {
    if (code.length < 6) {
      if (_error.isNotEmpty) setState(() => _error = '');
      return;
    }
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await checkPhoneCode(widget.phone, code);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = accountErrorText(context, error);
          _round++;
          _busy = false;
        });
      }
    }
  }

  Future<void> _resend() async {
    final l10n = AppLocalizations.of(context);
    try {
      // The same code, now by SMS.
      await sendPhoneCode(widget.phone, 'sms');
      if (mounted) {
        showTopNotice(context, l10n.phoneCodeResent);
        setState(_startTimer);
      }
    } catch (error) {
      if (mounted) showAccountError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.phoneCodeTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.zc.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.phoneCodeBody(_masked),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: context.zc.soft),
            ),
            const SizedBox(height: 24),
            CodeInput(
              key: ValueKey(_round),
              length: 6,
              autofocus: true,
              onChanged: _onChanged,
            ),
            SizedBox(
              height: 40,
              child: Center(
                child: Text(
                  _error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.red,
                  ),
                ),
              ),
            ),
            Center(
              child: _left > 0
                  ? Text(
                      l10n.phoneCodeResendIn(
                        '${_left ~/ 60}:${(_left % 60).toString().padLeft(2, '0')}',
                      ),
                      style: TextStyle(fontSize: 15, color: context.zc.soft),
                    )
                  : UnderlinedLink(text: l10n.phoneCodeResend, onTap: _resend),
            ),
          ],
        ),
      ),
    );
  }
}
