import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'recipient.dart';
import 'send_amount_screen.dart';
import 'send_ui.dart';

/// "Send money", step 3: shown right after "Send".
///
/// A transfer is only complete once the Mobile Money payment is confirmed
/// AND the recipient confirms in the app, so the page says it is on its
/// way, shows the receipt and the three steps.
class SendSuccessScreen extends StatelessWidget {
  const SendSuccessScreen({
    super.key,
    required this.recipient,
    required this.paid,
    required this.received,
    required this.fee,
    required this.currency,
    this.note = '',
    this.fromBalance = false,
    this.sentAt,
  });

  final Recipient recipient;
  final double paid;
  final double received;
  final double fee;
  final String currency;
  final String note;

  /// Paid with the Zawapay balance (no Mobile Money confirmation needed).
  final bool fromBalance;
  final DateTime? sentAt;

  /// Demo reference; the server will give the real one.
  String get _reference {
    final time = (sentAt ?? DateTime.now()).millisecondsSinceEpoch;
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
    final symbol = currencySymbol(currency);
    String amount(double value) => '${money.format(value)} $symbol';
    final date = DateFormat.yMMMd(locale)
        .add_Hm()
        .format(sentAt ?? DateTime.now());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        // Back goes home: the transfer is already on its way.
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.black,
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
                      const Center(child: _SentMark()),
                      const SizedBox(height: 22),
                      Text(
                        l10n.sentTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: SendColors.soft,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          amount(received),
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${l10n.sentTo} ',
                            style: const TextStyle(
                              fontSize: 17,
                              color: SendColors.soft,
                            ),
                          ),
                          Flexible(
                            child: RecipientHandle(recipient: recipient),
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
                                RecipientAvatar(recipient: recipient, size: 44),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recipient.fullName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      Text(
                                        recipient.fullPhone,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: SendColors.soft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 28, color: SendColors.field),
                            _Line(l10n.sendYouPay, amount(paid)),
                            _Line(l10n.sentFee, amount(fee)),
                            _Line(
                              l10n.sendReceives,
                              amount(received),
                              strong: true,
                            ),
                            if (note.isNotEmpty) _Line(l10n.sentNote, note),
                            _Line(l10n.sentReference, _reference),
                            _Line(l10n.sentDate, date),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      FramedCard(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Step(
                              state: _StepState.current,
                              title: fromBalance
                                  ? l10n.sentStepBalance
                                  : l10n.sentStepPayment,
                              body: fromBalance
                                  ? l10n.sentStepBalanceBody
                                  : l10n.sentStepPaymentBody,
                            ),
                            _Step(
                              state: _StepState.waiting,
                              title: l10n.sentStepPayout,
                              body: l10n.sentStepPayoutBody(recipient.handle),
                            ),
                            _Step(
                              state: _StepState.waiting,
                              title: l10n.sentStepConfirm,
                              body: l10n.sentStepConfirmBody(recipient.handle),
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
class _SentMark extends StatelessWidget {
  const _SentMark();

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
                    child: const Icon(
                      Icons.send_rounded,
                      color: AppColors.white,
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

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.strong = false});

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
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: SendColors.soft),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: strong ? 17 : 15,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepState { current, waiting }

/// One step of the transfer, linked to the next by a thin line.
class _Step extends StatelessWidget {
  const _Step({
    required this.state,
    required this.title,
    required this.body,
    this.last = false,
  });

  final _StepState state;
  final String title;
  final String body;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final current = state == _StepState.current;

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
                    color: current ? AppColors.red : Colors.transparent,
                    border: Border.all(
                      color: current ? AppColors.red : const Color(0x4DFFFFFF),
                      width: 2,
                    ),
                  ),
                  child: current
                      ? const Padding(
                          padding: EdgeInsets.all(4),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : null,
                ),
                if (!last)
                  const Expanded(
                    child: SizedBox(
                      width: 2,
                      child: ColoredBox(color: SendColors.field),
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
                      color: current ? AppColors.white : SendColors.soft,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: SendColors.soft,
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
