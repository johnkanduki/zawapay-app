import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/account/app_rules.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../l10n/app_localizations.dart';
import '../send/send_success_screen.dart';
import '../send/send_ui.dart';
import '../support/contact_sheet.dart';

/// "Withdrawal in progress", right after the PIN: the amount, the number,
/// the receipt and two steps (sent to Mobile Money, then received).
class WithdrawPendingScreen extends StatelessWidget {
  const WithdrawPendingScreen({
    super.key,
    required this.amount,
    required this.fee,
    required this.currency,
    required this.phone,
    this.at,
  });

  final double amount;
  final double fee;
  final String currency;
  final String phone;
  final DateTime? at;

  /// Temporary reference until the server gives the real one.
  String get _reference {
    final time = (at ?? DateTime.now()).millisecondsSinceEpoch;
    return 'ZR-${(time % 100000000).toString().padLeft(8, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final money = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    );
    String text(double v) => '${money.format(v)} $currency';
    final date = DateFormat.yMMMd(locale).add_Hm().format(at ?? DateTime.now());
    void home() => Navigator.of(context).popUntil((route) => route.isFirst);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.zc.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: PopScope(
        // Back goes home: the withdrawal is already on its way.
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) home();
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
                          onTap: home,
                        ),
                      ),
                      const Center(child: SentMark()),
                      const SizedBox(height: 22),
                      Text(
                        l10n.withdrawPendingTitle,
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
                          text(amount),
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                            color: context.zc.text,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${l10n.withdrawTo} $phone',
                          style: TextStyle(
                            fontSize: 17,
                            color: context.zc.soft,
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      FramedCard(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                        child: Column(
                          children: [
                            ReceiptLine(
                              l10n.withdrawAmount,
                              text(amount + fee),
                            ),
                            ReceiptLine(
                              feeLabel(
                                context,
                                send: false,
                                fallback: l10n.withdrawFee,
                              ),
                              fee == 0 ? l10n.withdrawFree : text(fee),
                            ),
                            ReceiptLine(
                              l10n.withdrawReceive,
                              text(amount),
                              strong: true,
                            ),
                            ReceiptLine(l10n.withdrawNumber, phone),
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
                              state: TransferStepState.current,
                              title: l10n.withdrawStepSent,
                              body: l10n.withdrawStepSentBody,
                            ),
                            StatusStep(
                              state: TransferStepState.waiting,
                              title: l10n.withdrawStepReceived,
                              body: l10n.withdrawStepReceivedBody(phone),
                              last: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Same "Contact support" as on a transfer's page.
                      SizedBox(
                        height: 56,
                        child: TextButton.icon(
                          onPressed: () => showContactSheet(context),
                          icon: const Icon(Icons.headset_mic_rounded),
                          label: Text(l10n.detailGetHelp),
                          style: TextButton.styleFrom(
                            backgroundColor: context.zc.field,
                            foregroundColor: context.zc.text,
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                      onPressed: home,
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
