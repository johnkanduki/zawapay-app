import 'package:flutter/material.dart';

import '../../core/account/withdraw_pin.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/code_input.dart';
import '../../core/widgets/underlined_link.dart';
import '../../l10n/app_localizations.dart';
import '../support/contact_sheet.dart';

/// Asks the 4-digit PIN before a withdrawal: created (typed twice) the very
/// first time, then simply typed. True once the PIN is right.
Future<bool> askWithdrawPin(BuildContext context, {WithdrawPin? pins}) async {
  final store = pins ?? withdrawPin;
  final create = !await store.exists();
  if (!context.mounted) return false;
  final ok = await showAppBottomSheet<bool>(
    context,
    showClose: true,
    builder: (_) => _PinForm(store: store, create: create),
  );
  return ok ?? false;
}

/// Settings → Security → "Code PIN": creates it (typed twice) when there is
/// none; otherwise the current one first, then the new one twice. The old
/// PIN stays until the new one is fully confirmed. True once saved.
Future<bool> changeWithdrawPin(
  BuildContext context, {
  WithdrawPin? pins,
}) async {
  final store = pins ?? withdrawPin;
  if (await store.exists()) {
    if (!context.mounted || !await askWithdrawPin(context, pins: store)) {
      return false;
    }
    final next = WithdrawPin(key: 'zawapay.withdraw_pin.next');
    await next.forget();
    if (!context.mounted || !await askWithdrawPin(context, pins: next)) {
      await next.forget();
      return false;
    }
    await store.takeFrom(next);
    return true;
  }
  if (!context.mounted) return false;
  return askWithdrawPin(context, pins: store);
}

class _PinForm extends StatefulWidget {
  const _PinForm({required this.store, required this.create});

  final WithdrawPin store;
  final bool create;

  @override
  State<_PinForm> createState() => _PinFormState();
}

class _PinFormState extends State<_PinForm> {
  static const _length = 4;

  /// Creation: the first code, waiting to be typed again.
  String? _first;
  String _error = '';

  /// A new key empties the boxes.
  int _round = 0;

  Future<void> _onChanged(String code) async {
    if (code.length < _length) {
      if (_error.isNotEmpty) setState(() => _error = '');
      return;
    }
    final l10n = AppLocalizations.of(context);
    if (widget.create && _first == null) {
      setState(() {
        _first = code;
        _round++;
      });
      return;
    }
    if (widget.create) {
      if (code != _first) {
        setState(() {
          _first = null;
          _error = l10n.pinMismatch;
          _round++;
        });
        return;
      }
      await widget.store.create(code);
      if (mounted) Navigator.of(context).pop(true);
      return;
    }
    if (await widget.store.check(code)) {
      if (mounted) Navigator.of(context).pop(true);
    } else if (mounted) {
      setState(() {
        _error = l10n.pinWrong;
        _round++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = !widget.create
        ? l10n.pinEnterTitle
        : _first == null
        ? l10n.pinCreateTitle
        : l10n.pinConfirmTitle;

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
              widget.create ? l10n.pinHelp : l10n.pinEnterBody,
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
            if (!widget.create)
              Center(
                child: UnderlinedLink(
                  text: l10n.pinForgot,
                  // A new PIN by e-mail code comes with the real
                  // withdrawals; until then the support helps.
                  onTap: () => showContactSheet(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
