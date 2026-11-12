import 'package:flutter/material.dart';

import '../../core/account/withdraw_pin.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/code_input.dart';
import '../../core/widgets/top_notice.dart';
import '../../core/widgets/underlined_link.dart';
import '../../l10n/app_localizations.dart';

/// Asks the 4-digit PIN (checked by the SERVER): created (typed twice) the
/// very first time, otherwise typed once. Returns the PIN once accepted, so
/// the caller sends it with the withdrawal or the number change; null when
/// closed. "Code PIN oublié ?" sends a code by e-mail to choose a new one.
Future<String?> askWithdrawPin(
  BuildContext context, {
  WithdrawPin? pins,
  bool forNumbers = false,
}) async {
  final store = pins ?? withdrawPin;
  final create = !await store.exists();
  if (!context.mounted) return null;
  return showAppBottomSheet<String>(
    context,
    showClose: true,
    builder: (_) => _PinForm(
      store: store,
      mode: create ? _Mode.create : _Mode.verify,
      forNumbers: forNumbers,
    ),
  );
}

/// Settings → Security → "Code PIN": creates it when there is none;
/// otherwise the current one first, then the new one twice (all checked by
/// the server). True once saved.
Future<bool> changeWithdrawPin(
  BuildContext context, {
  WithdrawPin? pins,
}) async {
  final store = pins ?? withdrawPin;
  if (!await store.exists()) {
    if (!context.mounted) return false;
    return await askWithdrawPin(context, pins: store) != null;
  }
  if (!context.mounted) return false;
  final current = await showAppBottomSheet<String>(
    context,
    showClose: true,
    builder: (_) => _PinForm(store: store, mode: _Mode.current),
  );
  if (current == null || !context.mounted) return false;
  final saved = await showAppBottomSheet<String>(
    context,
    showClose: true,
    builder: (_) =>
        _PinForm(store: store, mode: _Mode.change, current: current),
  );
  return saved != null;
}

enum _Mode { verify, current, create, change, resetCode, resetNew }

class _PinForm extends StatefulWidget {
  const _PinForm({
    required this.store,
    required this.mode,
    this.current,
    this.forNumbers = false,
  });

  final WithdrawPin store;
  final _Mode mode;
  final String? current;
  final bool forNumbers;

  @override
  State<_PinForm> createState() => _PinFormState();
}

class _PinFormState extends State<_PinForm> {
  late _Mode _mode = widget.mode;

  /// Creating: the first code, waiting to be typed again.
  String? _first;
  String _error = '';
  bool _busy = false;

  /// « Code PIN oublié »: where the code was sent, and the code typed.
  String _sentTo = '';
  String _emailCode = '';

  /// A new key empties the boxes.
  int _round = 0;

  int get _length => _mode == _Mode.resetCode ? 6 : 4;
  bool get _twice =>
      _mode == _Mode.create || _mode == _Mode.change || _mode == _Mode.resetNew;

  void _fail(String message) => setState(() {
    _first = null;
    _error = message;
    _round++;
    _busy = false;
  });

  Future<void> _onChanged(String code) async {
    if (code.length < _length) {
      if (_error.isNotEmpty) setState(() => _error = '');
      return;
    }
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    if (_mode == _Mode.resetCode) {
      setState(() {
        _emailCode = code;
        _mode = _Mode.resetNew;
        _round++;
      });
      return;
    }
    if (_twice && _first == null) {
      setState(() {
        _first = code;
        _round++;
      });
      return;
    }
    if (_twice && code != _first) return _fail(l10n.pinMismatch);
    setState(() => _busy = true);
    final error = switch (_mode) {
      _Mode.verify || _Mode.current => await widget.store.check(code),
      _Mode.create => await widget.store.create(code),
      _Mode.change => await widget.store.change(widget.current!, code),
      _ => await widget.store.confirmReset(_emailCode, code),
    };
    if (!mounted) return;
    if (error != null) {
      // A wrong e-mail code: type it again.
      if (_mode == _Mode.resetNew && error.toLowerCase().contains('code')) {
        setState(() => _mode = _Mode.resetCode);
      }
      return _fail(error);
    }
    if (_mode == _Mode.resetNew) {
      // New PIN by e-mail: withdrawals wait 24 h, said at once.
      Navigator.of(context).pop();
      showTopNotice(context, l10n.pinResetDone, icon: Icons.info_rounded);
      return;
    }
    Navigator.of(context).pop(code);
  }

  Future<void> _forgot() async {
    setState(() => _busy = true);
    final sentTo = await widget.store.startReset();
    if (!mounted) return;
    if (sentTo == null) {
      return _fail(AppLocalizations.of(context).errorGeneric);
    }
    setState(() {
      _sentTo = sentTo;
      _mode = _Mode.resetCode;
      _first = null;
      _error = '';
      _round++;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = switch (_mode) {
      _Mode.verify => l10n.pinEnterTitle,
      _Mode.current => l10n.pinCurrentTitle,
      _Mode.resetCode => l10n.pinResetTitle,
      _Mode.create =>
        _first == null ? l10n.pinCreateTitle : l10n.pinConfirmTitle,
      _ => _first == null ? l10n.pinNewTitle : l10n.pinConfirmTitle,
    };
    final body = switch (_mode) {
      _Mode.verify =>
        widget.forNumbers ? l10n.pinChangeBody : l10n.pinEnterBody,
      _Mode.current => l10n.pinEnterBody,
      _Mode.resetCode => l10n.pinResetBody(_sentTo),
      _Mode.create => l10n.pinHelp,
      _ => l10n.pinNewBody,
    };

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: context.zc.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: context.zc.soft),
            ),
            const SizedBox(height: 24),
            CodeInput(
              key: ValueKey(_round),
              length: _length,
              obscure: true,
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
            // Forgot: a code by e-mail, then a new PIN (withdrawals 24 h later).
            if (_mode == _Mode.verify || _mode == _Mode.current)
              Center(
                child: UnderlinedLink(
                  text: l10n.pinForgot,
                  onTap: _busy ? () {} : _forgot,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
