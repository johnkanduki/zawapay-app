import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/account/app_rules.dart';
import '../../core/account/zawapay_account.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../l10n/app_localizations.dart';
import 'recipient.dart';
import 'send_amount_screen.dart';
import 'send_ui.dart';

/// "Send money", step 3: shown right after "Send".
///
/// A transfer is only complete once the Mobile Money payment is confirmed
/// AND the recipient confirms in the app, so the page says it is on its
/// way, shows the receipt and the three steps.
class SendSuccessScreen extends StatefulWidget {
  const SendSuccessScreen({
    super.key,
    required this.recipient,
    required this.paid,
    required this.received,
    required this.fee,
    required this.currency,
    this.payCurrency,
    this.note = '',
    this.fromBalance = false,
    this.sentAt,
    this.transferId,
    this.reference,
  });

  final Recipient recipient;
  final double paid;
  final double received;
  final double fee;

  /// Currency of [received] (the recipient's).
  final String currency;

  /// Currency of [paid] and [fee] when it differs (abroad: the sender pays
  /// in USD, the recipient gets UGX…).
  final String? payCurrency;
  final String note;

  /// Paid with the Zawapay balance (no Mobile Money confirmation needed).
  final bool fromBalance;
  final DateTime? sentAt;

  /// The real transfer on the server: the page then follows it live.
  final String? transferId;
  final String? reference;

  @override
  State<SendSuccessScreen> createState() => _SendSuccessScreenState();
}

class _SendSuccessScreenState extends State<SendSuccessScreen> {
  /// Server status: created, collecting, collected, paying_out, paid_out,
  /// confirmed, collect_failed, payout_failed, refunded.
  String _status = 'collecting';
  Timer? _timer;

  static const _finished = {
    'confirmed',
    'collect_failed',
    'payout_failed',
    'refunded',
  };

  @override
  void initState() {
    super.initState();
    if (widget.transferId != null) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refresh());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Reads where the transfer stands; stops once it is over.
  Future<void> _refresh() async {
    try {
      final t = await zawapayAccount.transfer(widget.transferId!);
      final status = t['status'] as String? ?? _status;
      if (!mounted) return;
      if (status != _status) setState(() => _status = status);
      if (_finished.contains(status)) _timer?.cancel();
    } catch (_) {
      // No network for a moment: tried again in 3 s.
    }
  }

  /// Each step: done, current, waiting or failed, from the server status.
  (TransferStepState, TransferStepState, TransferStepState) get _steps =>
      switch (_status) {
        'collected' || 'paying_out' => (
          TransferStepState.done,
          TransferStepState.current,
          TransferStepState.waiting,
        ),
        'paid_out' => (
          TransferStepState.done,
          TransferStepState.done,
          TransferStepState.current,
        ),
        'confirmed' => (
          TransferStepState.done,
          TransferStepState.done,
          TransferStepState.done,
        ),
        'collect_failed' => (
          TransferStepState.failed,
          TransferStepState.waiting,
          TransferStepState.waiting,
        ),
        'payout_failed' || 'refunded' => (
          TransferStepState.done,
          TransferStepState.failed,
          TransferStepState.waiting,
        ),
        _ => (
          TransferStepState.current,
          TransferStepState.waiting,
          TransferStepState.waiting,
        ),
      };

  /// Temporary reference until the server gives the real one.
  String get _reference {
    if (widget.reference != null) return widget.reference!;
    final time = (widget.sentAt ?? DateTime.now()).millisecondsSinceEpoch;
    return 'ZP-${(time % 100000000).toString().padLeft(8, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final money = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    );
    final whole = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 0,
    );
    String amountIn(double value, String code) =>
        '${(code == 'USD' || code == 'CDF' ? money : whole).format(value)} '
        '${currencySymbol(code)}';
    // What the recipient gets, in their currency…
    String amount(double value) => amountIn(value, widget.currency);
    // … and what the sender pays.
    String paidAmount(double value) =>
        amountIn(value, widget.payCurrency ?? widget.currency);
    final date = DateFormat.yMMMd(locale)
        .add_Hm()
        .format(widget.sentAt ?? DateTime.now());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.zc.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: PopScope(
        // Back goes home: the transfer is already on its way.
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: Scaffold(
          backgroundColor: context.zc.page,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: RoundIconButton(
                          icon: Icons.close_rounded,
                          onTap: () =>
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst),
                        ),
                      ),
                      const Center(child: SentMark()),
                      const SizedBox(height: 22),
                      Text(
                        _steps.$1 == TransferStepState.failed ||
                                _steps.$2 == TransferStepState.failed
                            ? l10n.sentFailedTitle
                            : _status == 'paid_out' || _status == 'confirmed'
                            ? l10n.sentDoneTitle
                            : l10n.sentTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: context.zc.soft,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          amount(widget.received),
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                            color: context.zc.text,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${l10n.sentTo} ',
                            style: TextStyle(
                              fontSize: 17,
                              color: context.zc.soft,
                            ),
                          ),
                          Flexible(
                            child: RecipientHandle(recipient: widget.recipient),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      FramedCard(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                RecipientAvatar(
                                  recipient: widget.recipient,
                                  size: 44,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.recipient.isNumber
                                            ? widget.recipient.fullPhone
                                            : widget.recipient.fullName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: context.zc.text,
                                        ),
                                      ),
                                      if (!widget.recipient.isNumber)
                                        Text(
                                          widget.recipient.fullPhone,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: context.zc.soft,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 28, color: context.zc.field),
                            ReceiptLine(
                              l10n.sendYouPay,
                              paidAmount(widget.paid),
                            ),
                            ReceiptLine(
                              feeLabel(
                                context,
                                send: true,
                                fallback: l10n.sentFee,
                              ),
                              paidAmount(widget.fee),
                            ),
                            ReceiptLine(
                              l10n.sendReceives,
                              amount(widget.received),
                              strong: true,
                            ),
                            if (widget.note.isNotEmpty)
                              ReceiptLine(l10n.sentNote, widget.note),
                            ReceiptLine(l10n.sentReference, _reference),
                            ReceiptLine(l10n.sentDate, date),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      FramedCard(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusStep(
                              state: _steps.$1,
                              title: widget.fromBalance
                                  ? l10n.sentStepBalance
                                  : l10n.sentStepPayment,
                              body: switch (_steps.$1) {
                                TransferStepState.failed =>
                                  l10n.sentStepPaymentFailed,
                                TransferStepState.done =>
                                  l10n.sentStepPaymentDone,
                                _ =>
                                  widget.fromBalance
                                      ? l10n.sentStepBalanceBody
                                      : l10n.sentStepPaymentBody,
                              },
                            ),
                            StatusStep(
                              state: _steps.$2,
                              title: l10n.sentStepPayout,
                              body: switch (_steps.$2) {
                                TransferStepState.failed =>
                                  l10n.sentStepPayoutFailed,
                                TransferStepState.done =>
                                  l10n.sentStepPayoutDone(
                                    widget.recipient.handle,
                                  ),
                                _ => l10n.sentStepPayoutBody(
                                  widget.recipient.handle,
                                ),
                              },
                              // To a number nobody confirms: the payout ends it.
                              last: widget.recipient.isNumber,
                            ),
                            if (!widget.recipient.isNumber)
                              StatusStep(
                                state: _steps.$3,
                                title: l10n.sentStepConfirm,
                                body: _steps.$3 == TransferStepState.done
                                    ? l10n.sentStepConfirmDone(
                                        widget.recipient.handle,
                                      )
                                    : l10n.sentStepConfirmBody(
                                        widget.recipient.handle,
                                      ),
                                last: true,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: AppColors.white,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(l10n.sentBackHome),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Red paper-plane mark that pops in, with soft rings around it.
class SentMark extends StatelessWidget {
  const SentMark({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      builder: (context, t, _) {
        final grow = t.clamp(0.0, 1.2);
        return SizedBox.square(
          dimension: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (final (size, alpha) in [(170.0, 0.08), (130.0, 0.16)])
                Container(
                  width: size * grow,
                  height: size * grow,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.red.withValues(alpha: alpha),
                  ),
                ),
              Transform.scale(
                scale: grow,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.red,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.red.withValues(alpha: 0.45),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Transform.rotate(
                    angle: -math.pi / 7,
                    child: Icon(
                      Icons.send_rounded,
                      color: context.zc.text,
                      size: 42,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ReceiptLine extends StatelessWidget {
  const ReceiptLine(this.label, this.value, {super.key, this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: context.zc.soft)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: strong ? 17 : 15,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
                color: context.zc.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum TransferStepState { done, current, waiting, failed }

/// One step of the transfer, linked to the next by a thin line.
class StatusStep extends StatelessWidget {
  const StatusStep({
    super.key,
    required this.state,
    required this.title,
    required this.body,
    this.last = false,
  });

  final TransferStepState state;
  final String title;
  final String body;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final current = state == TransferStepState.current;
    final done = state == TransferStepState.done;
    final failed = state == TransferStepState.failed;
    final active = current || done || failed;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: current || done ? AppColors.red : Colors.transparent,
                    border: Border.all(
                      color: active ? AppColors.red : context.zc.faint,
                      width: 2,
                    ),
                  ),
                  child: done
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: AppColors.white,
                        )
                      : failed
                      ? const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: AppColors.red,
                        )
                      : current
                      ? Padding(
                          padding: EdgeInsets.all(4),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : null,
                ),
                if (!last)
                  Expanded(
                    child: SizedBox(
                      width: 2,
                      child: ColoredBox(
                        color: done ? AppColors.red : context.zc.field,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: active ? context.zc.text : context.zc.soft,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: context.zc.soft,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
