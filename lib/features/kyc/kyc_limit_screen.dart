import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/account/account_error.dart';
import '../../core/account/zawapay_account.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/verified_badge.dart';
import '../../l10n/app_localizations.dart';
import '../send/send_ui.dart';

/// The server calls of this page; tests replace them.
Future<Map<String, dynamic>> Function() loadLimit = zawapayAccount.myLimit;
Future<String> Function() openKycSession = zawapayAccount.startKyc;

/// Opens the Didit check INSIDE the app (an in-app browser sheet, never the
/// phone's browser app).
Future<bool> Function(Uri) showInApp = (uri) =>
    launchUrl(uri, mode: LaunchMode.inAppBrowserView);

/// Settings → « Limite quotidienne »: a short page. Without an identity
/// check, sending is limited per day (set in the admin dashboard); once
/// verified (Didit), the @ is certified and the limit is gone.
class KycLimitScreen extends StatefulWidget {
  const KycLimitScreen({super.key});

  @override
  State<KycLimitScreen> createState() => _KycLimitScreenState();
}

class _KycLimitScreenState extends State<KycLimitScreen>
    with WidgetsBindingObserver {
  Map<String, dynamic>? _limit;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Back from the Didit sheet: read the result again.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    try {
      final l = await loadLimit();
      if (mounted) setState(() => _limit = l);
    } catch (_) {}
  }

  Future<void> _verify() async {
    setState(() => _busy = true);
    try {
      final url = await openKycSession();
      await showInApp(Uri.parse(url));
      await _load();
    } catch (error) {
      if (mounted) showAccountError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final l = _limit;
    String usd(Object? v) =>
        '${NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: (v is num && v == v.roundToDouble()) ? 0 : 2).format(v is num ? v : 0)} \$';
    final certified = l?['certified'] == true;
    final limit = l?['limitUsd'];
    final pending =
        '${l?['kycStatus'] ?? ''}'.isNotEmpty &&
        !certified &&
        !const {'Declined', 'Abandoned', 'Expired'}.contains(l?['kycStatus']);

    Widget benefit(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.red.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: AppColors.red),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: context.zc.text,
              ),
            ),
          ),
        ],
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.zc.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.zc.page,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              certified ? l10n.kycDoneTitle : l10n.kycTitle2,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                                color: context.zc.text,
                              ),
                            ),
                          ),
                          if (certified) const VerifiedBadge(size: 28),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (l != null && !certified && limit != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.zc.card,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.kycToday(
                                  usd(l['usedTodayUsd']),
                                  usd(limit),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: context.zc.text,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value:
                                      ((l['usedTodayUsd'] as num? ?? 0) /
                                              (limit as num))
                                          .clamp(0.0, 1.0)
                                          .toDouble(),
                                  minHeight: 10,
                                  color: AppColors.red,
                                  backgroundColor: context.zc.field,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (certified)
                        Text(
                          l10n.kycDoneText,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.45,
                            color: context.zc.soft,
                          ),
                        ),
                      const SizedBox(height: 22),
                      if (!certified) ...[
                        benefit(
                          Icons.trending_up_rounded,
                          l10n.kycBenefit1(usd(limit ?? 100)),
                        ),
                        benefit(Icons.verified_rounded, l10n.kycBenefit2),
                        benefit(Icons.shield_rounded, l10n.kycBenefit3),
                        const SizedBox(height: 6),
                        Text(
                          pending ? l10n.kycPending : l10n.kycHow,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: pending
                                ? const Color(0xFFB7791F)
                                : context.zc.soft,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!certified)
                  SizedBox(
                    height: 60,
                    child: FilledButton(
                      onPressed: _busy || l == null ? null : _verify,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.red.withValues(
                          alpha: 0.35,
                        ),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: _busy
                          ? const SizedBox.square(
                              dimension: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.6,
                                color: AppColors.white,
                              ),
                            )
                          : Text(l10n.kycButton),
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
