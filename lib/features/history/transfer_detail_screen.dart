import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/top_notice.dart';
import '../../l10n/app_localizations.dart';
import '../send/recipient.dart';
import '../send/send_ui.dart';
import '../support/contact_sheet.dart';
import 'transfer.dart';

/// Detail of one transfer, opened from the history.
///
/// Top: the status at a glance (amount + Successful / In progress / Failed)
/// and the steps of the transfer. Then the other person (by "@"), the
/// amounts, the IDs to copy, and help (plus "Try again" when it failed).
class TransferDetailScreen extends StatelessWidget {
  const TransferDetailScreen({super.key, required this.transfer});

  final Transfer transfer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    String money(double value) => formatMoney(value, transfer.currency, locale);
    final failed = transfer.status == TransferStatus.failed;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.zc.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.zc.page,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: RoundIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 18),
              _StatusHeader(
                transfer: transfer,
                amount: money(transfer.received),
              ),
              const SizedBox(height: 16),
              FramedCard(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(l10n.detailStatusTitle),
                    const SizedBox(height: 16),
                    ..._steps(context),
                    const _Divider(),
                    _SectionTitle(
                      transfer.outgoing
                          ? l10n.detailRecipient
                          : l10n.detailSender,
                    ),
                    const SizedBox(height: 14),
                    _PersonRow(person: transfer.other),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              l10n.detailSeeAllWith(transfer.other.handle),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.red,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.red,
                          ),
                        ],
                      ),
                    ),
                    const _Divider(),
                    _SectionTitle(l10n.detailAmountTitle),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      decoration: BoxDecoration(
                        color: context.zc.field,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _Line(
                            l10n.detailTransferAmount,
                            money(transfer.received),
                          ),
                          _Line(l10n.detailFee, money(transfer.fee)),
                          _Line(l10n.detailTotalPaid, money(transfer.paid)),
                          Divider(height: 22, color: context.zc.field),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.detailTotalReceived,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: context.zc.text,
                                  ),
                                ),
                              ),
                              Text(
                                money(transfer.received),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: context.zc.text,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const _Divider(),
                    _SectionTitle(l10n.detailInfoTitle),
                    const SizedBox(height: 14),
                    _Line(
                      wideValue: true,
                      l10n.detailSentOn,
                      DateFormat.yMMMd(locale).add_Hm().format(transfer.sentAt),
                    ),
                    _CopyLine(label: l10n.detailTransferId, value: transfer.id),
                    _CopyLine(
                      label: l10n.detailReferenceId,
                      value: transfer.reference,
                    ),
                    const SizedBox(height: 18),
                    if (failed) ...[
                      _WideButton(
                        label: l10n.detailTryAgain,
                        icon: Icons.refresh_rounded,
                        primary: true,
                        onTap: () {},
                      ),
                      const SizedBox(height: 10),
                    ],
                    _WideButton(
                      label: l10n.detailGetHelp,
                      icon: Icons.headset_mic_rounded,
                      primary: false,
                      onTap: () => showContactSheet(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The steps, depending on the status.
  List<Widget> _steps(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final handle = transfer.other.handle;
    final submitted = _StepRow(
      state: _Step.done,
      title: l10n.detailStepSubmitted,
      time: transfer.sentAt,
    );

    return switch (transfer.status) {
      TransferStatus.success => [
        submitted,
        _StepRow(
          state: _Step.done,
          title: l10n.detailStepPaid,
          time: transfer.paidAt,
        ),
        _StepRow(
          state: _Step.done,
          title: l10n.detailStepConfirmed(handle),
          time: transfer.confirmedAt,
          last: true,
        ),
      ],
      TransferStatus.pending => [
        submitted,
        _StepRow(
          state: _Step.done,
          title: l10n.detailStepPaid,
          time: transfer.paidAt,
        ),
        _StepRow(
          state: _Step.current,
          title: transfer.outgoing
              ? l10n.detailStepWaitingRecipient(handle)
              : l10n.detailStepWaitingYou,
          last: true,
        ),
      ],
      TransferStatus.failed => [
        submitted,
        _StepRow(
          state: _Step.failed,
          title: l10n.detailStepFailed,
          time: transfer.failedAt,
          last: true,
        ),
      ],
    };
  }
}

/// Big status at the top: icon, label and amount.
class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.transfer, required this.amount});

  final Transfer transfer;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, label, filled) = switch (transfer.status) {
      TransferStatus.success => (Icons.check_rounded, l10n.statusSuccess, true),
      TransferStatus.pending => (
        Icons.schedule_rounded,
        l10n.statusPending,
        false,
      ),
      TransferStatus.failed => (Icons.close_rounded, l10n.statusFailed, false),
    };

    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? AppColors.red
                : AppColors.red.withValues(alpha: 0.16),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: AppColors.red.withValues(alpha: 0.4),
                      blurRadius: 26,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 38,
            color: filled ? AppColors.white : AppColors.red,
          ),
        ),
        const SizedBox(height: 14),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${transfer.outgoing ? '-' : '+'}$amount',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
              color: context.zc.text,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: ShapeDecoration(
            color: transfer.status == TransferStatus.success
                ? context.zc.text.withValues(alpha: 0.12)
                : AppColors.red.withValues(alpha: 0.16),
            shape: const StadiumBorder(),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: transfer.status == TransferStatus.success
                  ? context.zc.text
                  : AppColors.red,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: context.zc.soft,
    ),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      Divider(height: 44, color: context.zc.field);
}

enum _Step { done, current, failed }

/// One step: round mark, title and time, linked to the next by a line.
class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.state,
    required this.title,
    this.time,
    this.last = false,
  });

  final _Step state;
  final String title;
  final DateTime? time;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final when = time == null ? null : _relative(l10n, locale, time!);
    final failed = state == _Step.failed;

    final Widget mark = switch (state) {
      _Step.done => const _Mark(
        color: AppColors.red,
        child: Icon(Icons.check_rounded, size: 18, color: AppColors.white),
      ),
      _Step.current => _Mark(
        color: AppColors.red.withValues(alpha: 0.18),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: AppColors.red,
          ),
        ),
      ),
      _Step.failed => _Mark(
        color: context.zc.isDark ? AppColors.white : context.zc.field,
        child: Icon(Icons.close_rounded, size: 18, color: AppColors.red),
      ),
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                mark,
                if (!last)
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: SizedBox(
                        width: 2,
                        child: ColoredBox(color: AppColors.red),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 5, bottom: last ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: failed ? 18 : 17,
                      height: 1.3,
                      fontWeight: state == _Step.done
                          ? FontWeight.w500
                          : FontWeight.w700,
                      color: failed ? AppColors.red : context.zc.text,
                    ),
                  ),
                  if (when != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      when,
                      style: TextStyle(fontSize: 14, color: context.zc.soft),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "Today at 20:08", "Yesterday at 15:07", or the date.
  static String _relative(AppLocalizations l10n, String locale, DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(t.year, t.month, t.day);
    final time = DateFormat.Hm(locale).format(t);
    final diff = today.difference(day).inDays;
    if (diff == 0) return l10n.todayAt(time);
    if (diff == 1) return l10n.yesterdayAt(time);
    return '${DateFormat.yMMMd(locale).format(t)}, $time';
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    alignment: Alignment.center,
    child: child,
  );
}

/// The other person: avatar with flag, "@" (badge), name and number.
class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.person});

  final Recipient person;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RecipientAvatar(recipient: person, size: 52),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RecipientHandle(recipient: person, fontSize: 19),
              const SizedBox(height: 2),
              Text(
                person.details,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: context.zc.soft),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.wideValue = false});

  final String label;
  final String value;

  /// Gives more room to a long value (the date).
  final bool wideValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      // Label on the left, value always against the right edge.
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: wideValue ? 2 : 3,
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: context.zc.soft),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: wideValue ? 3 : 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 15, color: context.zc.text),
            ),
          ),
        ],
      ),
    );
  }
}

/// A long ID shown short ("526180…692553") with a copy button.
class _CopyLine extends StatelessWidget {
  const _CopyLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final short = value.length > 14
        ? '${value.substring(0, 6)}…${value.substring(value.length - 6)}'
        : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 3,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, color: context.zc.soft),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 3,
            child: Text(
              short,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, color: context.zc.text),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              // Messages always come down from the top.
              showTopNotice(context, l10n.detailCopied);
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.zc.field,
              ),
              child: Icon(Icons.copy_rounded, size: 17, color: context.zc.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _WideButton extends StatelessWidget {
  const _WideButton({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: primary ? AppColors.red : context.zc.field,
          foregroundColor: context.zc.text,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
