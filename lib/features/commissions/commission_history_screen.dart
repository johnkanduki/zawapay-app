import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/account/zawapay_account.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../l10n/app_localizations.dart';
import '../invite/invite_screen.dart';
import '../send/send_ui.dart';

/// Reads the history from the server; tests replace it.
Future<Map<String, dynamic>> Function() loadCommissionHistory =
    zawapayAccount.commissionHistory;

/// « Historique des commissions », opened by tapping the Zawapay balance:
/// every dollar of the balance and where it comes from — which transfer,
/// who sent it, at which level, the REAL percentage applied and the share —
/// and every withdrawal (minus) or returned withdrawal (plus). Everything
/// comes from the server's money register: nothing is invented here.
class CommissionHistoryScreen extends StatefulWidget {
  const CommissionHistoryScreen({super.key, required this.username});

  final String username;

  @override
  State<CommissionHistoryScreen> createState() =>
      _CommissionHistoryScreenState();
}

class _CommissionHistoryScreenState extends State<CommissionHistoryScreen> {
  Map<String, dynamic>? _history;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final h = await loadCommissionHistory();
      if (mounted) setState(() => (_history = h, _failed = false));
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final h = _history;
    double n(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
    String usd(Object? v) =>
        '${NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 2).format(n(v))} USD';

    final children = <Widget>[
      Row(
        children: [
          RoundIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.commissionsTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: context.zc.text,
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
    ];

    if (h == null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Center(
            child: _failed
                ? Text(
                    l10n.commissionsLoadFailed,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: context.zc.soft),
                  )
                : const CircularProgressIndicator(color: AppColors.red),
          ),
        ),
      );
    } else {
      final items = (h['items'] as List).cast<Map<String, dynamic>>();
      children.addAll([
        _Summary(
          available: usd(h['available']),
          pending: n(h['pending']) > 0
              ? l10n.commissionsPending(usd(h['pending']))
              : null,
          earned: usd(h['earned']),
          withdrawn: usd(h['withdrawn']),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.commissionsIntro,
          style: TextStyle(fontSize: 14, height: 1.4, color: context.zc.soft),
        ),
        const SizedBox(height: 16),
      ]);
      if (items.isEmpty) {
        children.addAll([
          const SizedBox(height: 20),
          Icon(Icons.savings_rounded, size: 48, color: context.zc.faint),
          const SizedBox(height: 10),
          Text(
            l10n.commissionsEmpty,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.4, color: context.zc.soft),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => InviteScreen(username: widget.username),
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: AppColors.white,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(l10n.commissionsInvite),
            ),
          ),
        ]);
      } else {
        for (final item in items) {
          children.add(_Line(item: item, usd: usd, n: n));
        }
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.zc.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.zc.page,
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.red,
            onRefresh: _load,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// The balance at the top, like the home card: available in big, then
/// pending, total earned and total withdrawn.
class _Summary extends StatelessWidget {
  const _Summary({
    required this.available,
    required this.pending,
    required this.earned,
    required this.withdrawn,
  });

  final String available;
  final String? pending;
  final String earned;
  final String withdrawn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget stat(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: context.zc.isDark
                  ? AppColors.grey
                  : const Color(0x99FFFFFF),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.zc.onInverse,
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: context.zc.inverse,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.commissionsAvailable,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.red,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              available,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: context.zc.onInverse,
              ),
            ),
          ),
          if (pending != null)
            Text(
              pending!,
              style: const TextStyle(fontSize: 14, color: Color(0xFFE0A800)),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              stat(l10n.commissionsEarned, earned),
              const SizedBox(width: 12),
              stat(l10n.commissionsWithdrawn, withdrawn),
            ],
          ),
        ],
      ),
    );
  }
}

/// One line of the register: a commission (+), a withdrawal or its fee (−),
/// or a returned withdrawal (+). Tap to see every detail.
class _Line extends StatefulWidget {
  const _Line({required this.item, required this.usd, required this.n});

  final Map<String, dynamic> item;
  final String Function(Object?) usd;
  final double Function(Object?) n;

  @override
  State<_Line> createState() => _LineState();
}

class _LineState extends State<_Line> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final item = widget.item;
    final amount = widget.n(item['amount']);
    final plus = amount >= 0;
    final kind = '${item['kind']}';
    final at = DateTime.tryParse('${item['createdAt']}')?.toLocal();
    final date = at == null ? '' : DateFormat.yMMMd(locale).add_Hm().format(at);
    String local(Object? v, Object? cur) {
      final value = widget.n(v);
      final whole = value == value.roundToDouble();
      return '${NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: whole ? 0 : 2).format(value)} $cur';
    }

    late final String title;
    late final String subtitle;
    String? status;
    Color statusColor = context.zc.soft;
    final details = <(String, String)>[];

    if (kind == 'commission') {
      final c = item['commission'] as Map<String, dynamic>?;
      title = c == null
          ? l10n.commissionsTitle
          : l10n.commissionsSent(
              '${c['sender']}',
              local(c['paid'], c['paidCurrency']),
            );
      final level = '${c?['level'] ?? ''}';
      final who = switch (level) {
        'up1' => l10n.commissionsUp1,
        'up2' => l10n.commissionsUp2,
        'up3' => l10n.commissionsUp3,
        'down1' => l10n.commissionsDown1,
        'down2' => l10n.commissionsDown2,
        _ => l10n.commissionsDown3,
      };
      final percent = '${c?['percent'] ?? ''} %';
      final shared = (c?['sharedWith'] as num? ?? 1) > 1;
      subtitle =
          '$who · ${shared ? l10n.commissionsShared(percent, '${c?['sharedWith']}') : l10n.commissionsShare(percent, widget.usd(c?['pool']))}';
      (status, statusColor) = switch ('${item['status']}') {
        'available' => (
          l10n.commissionsStatusAvailable,
          const Color(0xFF1E9E5A),
        ),
        'pending' => (l10n.commissionsStatusPending, const Color(0xFFB7791F)),
        _ => (l10n.commissionsStatusCancelled, AppColors.red),
      };
      if (c != null) {
        details.addAll([
          (l10n.commissionsRef, '${c['reference']}'),
          (l10n.commissionsSentLabel, local(c['paid'], c['paidCurrency'])),
          (
            l10n.commissionsReceivedLabel,
            local(c['received'], c['receivedCurrency']),
          ),
          (l10n.commissionsPoolLabel, widget.usd(c['pool'])),
          (l10n.commissionsPercentLabel, percent),
        ]);
      }
    } else if (kind == 'withdrawal' || kind == 'withdrawal_fee') {
      final w = item['withdrawal'] as Map<String, dynamic>?;
      title = kind == 'withdrawal'
          ? l10n.commissionsWithdrawal
          : l10n.commissionsWithdrawalFee;
      subtitle = w == null || kind == 'withdrawal_fee'
          ? ''
          : l10n.commissionsWithdrawalGot(
              local(w['receive'], w['currency']),
              '${w['phone'] ?? ''}',
            );
      if (kind == 'withdrawal' && w != null) {
        (status, statusColor) = switch ('${w['status']}') {
          'SUCCESS' => (l10n.commissionsWdDone, const Color(0xFF1E9E5A)),
          'FAILED' || 'CANCELLED' => (l10n.commissionsWdFailed, AppColors.red),
          _ => (l10n.commissionsWdPending, const Color(0xFFB7791F)),
        };
        details.add((l10n.commissionsRef, '${w['reference']}'));
      }
    } else {
      title = l10n.commissionsReturned;
      subtitle = '';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: details.isEmpty ? null : () => setState(() => _open = !_open),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.zc.card,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (plus ? const Color(0xFF1E9E5A) : AppColors.red)
                          .withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      plus
                          ? Icons.south_west_rounded
                          : Icons.north_east_rounded,
                      size: 20,
                      color: plus ? const Color(0xFF1E9E5A) : AppColors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: context.zc.text,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              color: context.zc.soft,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          [date, ?status].join(' · '),
                          style: TextStyle(fontSize: 12, color: statusColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${plus ? '+' : '−'}${widget.usd(amount.abs())}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: plus ? const Color(0xFF1E9E5A) : context.zc.text,
                    ),
                  ),
                ],
              ),
              if (_open && details.isNotEmpty) ...[
                Divider(height: 22, color: context.zc.field),
                for (final (label, value) in details)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.zc.soft,
                            ),
                          ),
                        ),
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.zc.text,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
