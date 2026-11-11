import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../l10n/app_localizations.dart';
import '../send/send_ui.dart';
import 'history_filter.dart';
import 'transfer.dart';
import 'transfer_detail_screen.dart';
import 'transfer_row.dart';

/// Full history, opened by "See all the history" on the home page.
///
/// Same lines as on the home page, with a "Filters" button styled like the
/// home "Hide" button.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.transfers});

  final List<Transfer> transfers;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryFilter _filter = const HistoryFilter();

  Future<void> _openFilter() async {
    final picked = await showHistoryFilter(
      context,
      current: _filter,
      transfers: widget.transfers,
    );
    if (picked != null && mounted) setState(() => _filter = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shown = _filter.apply(widget.transfers);
    final active = _filter.activeCount;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.zc.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.zc.page,
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
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
              FramedCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 12, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.homeActivity,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.6,
                                color: context.zc.text,
                              ),
                            ),
                          ),
                          _FilterButton(active: active, onTap: _openFilter),
                        ],
                      ),
                    ),
                    // Results line with "Clear", only while filtering.
                    if (active > 0)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 20, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.historyResults(shown.length),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.zc.soft,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(
                                () => _filter = const HistoryFilter(),
                              ),
                              child: Text(
                                l10n.historyClear,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Divider(height: 1, color: context.zc.card),
                    const SizedBox(height: 6),
                    if (shown.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 40,
                        ),
                        child: Text(
                          widget.transfers.isEmpty
                              ? l10n.homeNoTransfers
                              : l10n.historyEmpty,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: context.zc.soft,
                          ),
                        ),
                      )
                    else
                      for (final transfer in shown)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: TransferRow(
                            transfer: transfer,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    TransferDetailScreen(transfer: transfer),
                              ),
                            ),
                          ),
                        ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Red pill like the home "Hide" button, with the number of active filters.
class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.onTap});

  final int active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
        decoration: ShapeDecoration(
          color: AppColors.red.withValues(alpha: 0.16),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune_rounded, size: 19, color: AppColors.red),
            const SizedBox(width: 6),
            Text(
              l10n.historyFilters,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.red,
              ),
            ),
            if (active > 0) ...[
              const SizedBox(width: 6),
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.red,
                ),
                child: Text(
                  '$active',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
