import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../send/recipient.dart';
import '../send/send_ui.dart';
import 'transfer.dart';

enum FilterType { all, sent, received }

enum FilterPeriod { all, thisMonth, days7, days30, days90, year }

/// What the history shows: one person (or everyone), the direction, the
/// status and the period. Everything "all" shows every transfer.
@immutable
class HistoryFilter {
  const HistoryFilter({
    this.person,
    this.type = FilterType.all,
    this.status,
    this.period = FilterPeriod.all,
  });

  /// Null: everyone.
  final Recipient? person;
  final FilterType type;

  /// Null: every status.
  final TransferStatus? status;
  final FilterPeriod period;

  /// How many filters differ from "all".
  int get activeCount => [
    person != null,
    type != FilterType.all,
    status != null,
    period != FilterPeriod.all,
  ].where((on) => on).length;

  HistoryFilter copyWith({
    Recipient? Function()? person,
    FilterType? type,
    TransferStatus? Function()? status,
    FilterPeriod? period,
  }) => HistoryFilter(
    person: person == null ? this.person : person(),
    type: type ?? this.type,
    status: status == null ? this.status : status(),
    period: period ?? this.period,
  );

  bool matches(Transfer t, DateTime now) {
    if (person != null && t.other.username != person!.username) return false;
    if (type == FilterType.sent && !t.outgoing) return false;
    if (type == FilterType.received && t.outgoing) return false;
    if (status != null && t.status != status) return false;
    final age = now.difference(t.sentAt).inDays;
    return switch (period) {
      FilterPeriod.all => true,
      FilterPeriod.thisMonth =>
        t.sentAt.year == now.year && t.sentAt.month == now.month,
      FilterPeriod.days7 => age < 7,
      FilterPeriod.days30 => age < 30,
      FilterPeriod.days90 => age < 90,
      FilterPeriod.year => age < 365,
    };
  }

  List<Transfer> apply(List<Transfer> all) {
    final now = DateTime.now();
    return all.where((t) => matches(t, now)).toList();
  }
}

/// "Filters" sheet. Returns the new filter, or null when closed.
Future<HistoryFilter?> showHistoryFilter(
  BuildContext context, {
  required HistoryFilter current,
  required List<Transfer> transfers,
}) {
  return showModalBottomSheet<HistoryFilter>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: AppColors.scrim,
    backgroundColor: Colors.transparent,
    builder: (_) => _FilterSheet(current: current, transfers: transfers),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.current, required this.transfers});

  final HistoryFilter current;
  final List<Transfer> transfers;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late HistoryFilter _filter = widget.current;

  /// Everyone the user has exchanged money with, once each.
  List<Recipient> get _people {
    final seen = <String>{};
    return [
      for (final t in widget.transfers)
        if (seen.add(t.other.username)) t.other,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = _filter.apply(widget.transfers).length;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: SendColors.field,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: RoundIconButton(
              icon: Icons.close_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(height: 16),
          FramedCard(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.historyFilters,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    // Clear only shows once something is filtered.
                    if (_filter.activeCount > 0)
                      GestureDetector(
                        onTap: () =>
                            setState(() => _filter = const HistoryFilter()),
                        child: Text(
                          l10n.historyClear,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.red,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.filterSubtitle,
                  style: const TextStyle(fontSize: 15, color: SendColors.soft),
                ),
                const SizedBox(height: 18),
                _PersonRow(person: _filter.person, onTap: _pickPerson),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MenuPill<FilterType>(
                        title: l10n.filterType,
                        value: _filter.type,
                        isAll: _filter.type == FilterType.all,
                        options: [
                          (FilterType.all, l10n.filterAll, null),
                          (FilterType.sent, l10n.filterSent, null),
                          (FilterType.received, l10n.filterReceived, null),
                        ],
                        onSelected: (v) =>
                            setState(() => _filter = _filter.copyWith(type: v)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MenuPill<TransferStatus?>(
                        title: l10n.filterStatus,
                        value: _filter.status,
                        isAll: _filter.status == null,
                        options: [
                          (null, l10n.filterAll, null),
                          (
                            TransferStatus.success,
                            l10n.statusSuccess,
                            const _Dot(filled: true, color: AppColors.white),
                          ),
                          (
                            TransferStatus.pending,
                            l10n.statusPending,
                            const _Dot(filled: false, color: AppColors.red),
                          ),
                          (
                            TransferStatus.failed,
                            l10n.statusFailed,
                            const _Dot(filled: true, color: AppColors.red),
                          ),
                        ],
                        onSelected: (v) => setState(
                          () => _filter = _filter.copyWith(status: () => v),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MenuPill<FilterPeriod>(
                        title: l10n.filterPeriod,
                        value: _filter.period,
                        isAll: _filter.period == FilterPeriod.all,
                        options: [
                          (FilterPeriod.all, l10n.periodAll, null),
                          (FilterPeriod.thisMonth, l10n.periodMonth, null),
                          (FilterPeriod.days7, l10n.periodDays(7), null),
                          (FilterPeriod.days30, l10n.periodDays(30), null),
                          (FilterPeriod.days90, l10n.periodDays(90), null),
                          (FilterPeriod.year, l10n.periodYear, null),
                        ],
                        onSelected: (v) => setState(
                          () => _filter = _filter.copyWith(period: v),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // The button already tells how many transfers will show.
          SizedBox(
            height: 60,
            child: FilledButton(
              onPressed: count == 0
                  ? null
                  : () => Navigator.of(context).pop(_filter),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                disabledBackgroundColor: AppColors.red.withValues(alpha: 0.35),
                foregroundColor: AppColors.white,
                disabledForegroundColor: SendColors.soft,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(l10n.filterShowResults(count)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPerson() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<_PersonChoice>(
      context: context,
      useSafeArea: true,
      barrierColor: AppColors.scrim,
      backgroundColor: AppColors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 12),
                child: Text(
                  l10n.filterPerson.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: SendColors.soft,
                  ),
                ),
              ),
              _PersonOption(
                selected: _filter.person == null,
                onTap: () => Navigator.of(sheet).pop(const _PersonChoice(null)),
                child: Row(
                  children: [
                    const _PeopleIcon(),
                    const SizedBox(width: 12),
                    Text(
                      l10n.filterEveryone,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              for (final person in _people)
                _PersonOption(
                  selected: _filter.person?.username == person.username,
                  onTap: () => Navigator.of(sheet).pop(_PersonChoice(person)),
                  child: Row(
                    children: [
                      RecipientAvatar(recipient: person, size: 40),
                      const SizedBox(width: 12),
                      Flexible(child: RecipientHandle(recipient: person)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) {
      setState(() => _filter = _filter.copyWith(person: () => picked.person));
    }
  }
}

/// Wraps the picked person so "everyone" (null) is not "closed".
class _PersonChoice {
  const _PersonChoice(this.person);
  final Recipient? person;
}

class _PeopleIcon extends StatelessWidget {
  const _PeopleIcon();

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.red.withValues(alpha: 0.16),
    ),
    child: const Icon(Icons.group_rounded, color: AppColors.red, size: 24),
  );
}

/// "Everyone" or the chosen person, opens the list of people.
class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.person, required this.onTap});

  final Recipient? person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final who = person;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
        decoration: ShapeDecoration(
          color: SendColors.field,
          shape: StadiumBorder(
            side: BorderSide(
              color: who == null ? Colors.transparent : AppColors.red,
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          children: [
            if (who == null)
              const _PeopleIcon()
            else
              RecipientAvatar(recipient: who, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: who == null
                  ? Text(
                      l10n.filterEveryone,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: RecipientHandle(recipient: who, fontSize: 16),
                    ),
            ),
            const Icon(Icons.chevron_right_rounded, color: SendColors.soft),
          ],
        ),
      ),
    );
  }
}

class _PersonOption extends StatelessWidget {
  const _PersonOption({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        decoration: ShapeDecoration(
          color: selected ? SendColors.field : Colors.transparent,
          shape: const StadiumBorder(),
        ),
        child: Row(
          children: [
            Expanded(child: child),
            if (selected) const Icon(Icons.check_rounded, color: AppColors.red),
          ],
        ),
      ),
    );
  }
}

/// Pill that opens a small menu; red like "Hide" once something is chosen.
class _MenuPill<T> extends StatelessWidget {
  const _MenuPill({
    required this.title,
    required this.value,
    required this.isAll,
    required this.options,
    required this.onSelected,
  });

  final String title;
  final T value;
  final bool isAll;
  final List<(T, String, Widget?)> options;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    // Once chosen, the pill shows the choice instead of the title.
    final label = isAll ? title : options.firstWhere((o) => o.$1 == value).$2;
    final active = !isAll;

    return PopupMenuButton<int>(
      tooltip: title,
      color: Color.alphaBlend(SendColors.field, AppColors.black),
      elevation: 12,
      offset: const Offset(0, 54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      onSelected: (i) => onSelected(options[i].$1),
      itemBuilder: (_) => [
        PopupMenuItem<int>(
          enabled: false,
          height: 34,
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: SendColors.soft,
            ),
          ),
        ),
        for (var i = 0; i < options.length; i++)
          PopupMenuItem<int>(
            value: i,
            height: 46,
            child: Row(
              children: [
                if (options[i].$3 != null) ...[
                  options[i].$3!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    options[i].$2,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: options[i].$1 == value
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: AppColors.white,
                    ),
                  ),
                ),
                if (options[i].$1 == value)
                  const Icon(Icons.check_rounded, color: AppColors.red),
              ],
            ),
          ),
      ],
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 46,
        padding: const EdgeInsets.fromLTRB(12, 0, 6, 0),
        decoration: ShapeDecoration(
          color: active
              ? AppColors.red.withValues(alpha: 0.16)
              : SendColors.field,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: active ? AppColors.red : AppColors.white,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: active ? AppColors.red : SendColors.soft,
            ),
          ],
        ),
      ),
    );
  }
}

/// Small status dot in the status menu.
class _Dot extends StatelessWidget {
  const _Dot({required this.filled, required this.color});

  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: filled ? color : Colors.transparent,
      border: Border.all(color: color, width: 2),
    ),
  );
}
