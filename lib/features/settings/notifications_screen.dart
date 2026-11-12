import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/account/account_error.dart';
import '../../core/account/zawapay_account.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../l10n/app_localizations.dart';
import '../send/send_ui.dart';

/// The server calls of this page; tests replace them.
Future<Map<String, dynamic>> Function() loadNotificationPrefs =
    zawapayAccount.notificationPrefs;
Future<Map<String, dynamic>> Function(Map<String, bool>) saveNotificationPrefs =
    zawapayAccount.saveNotificationPrefs;

/// Settings → « Notifications »: three switches, saved on the server at
/// once — transfers sent and received, commissions and withdrawals, news.
/// The server only sends the alerts that are switched on.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Map<String, bool>? _prefs;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await loadNotificationPrefs();
      if (mounted) {
        setState(() {
          _prefs = {
            for (final k in const ['transfers', 'commissions', 'news'])
              k: p[k] != false,
          };
          _failed = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _set(String key, bool value) async {
    final before = _prefs!;
    setState(() => _prefs = {...before, key: value});
    try {
      await saveNotificationPrefs({key: value});
    } catch (error) {
      // Not saved: the switch goes back, and the reason shows.
      if (mounted) {
        setState(() => _prefs = before);
        showAccountError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = _prefs;

    Widget toggle(String key, String title, String help, IconData icon) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: context.zc.card,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.zc.field,
              ),
              child: Icon(icon, color: context.zc.text),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.zc.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    help,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: context.zc.soft,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: prefs![key] ?? true,
              activeTrackColor: AppColors.red,
              onChanged: (v) => _set(key, v),
            ),
          ],
        ),
      );
    }

    final children = <Widget>[
      Row(
        children: [
          RoundIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 14),
          Text(
            l10n.notifTitle,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.zc.text,
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      Text(
        l10n.notifIntro,
        style: TextStyle(fontSize: 15, height: 1.4, color: context.zc.soft),
      ),
      const SizedBox(height: 16),
    ];
    if (prefs == null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Center(
            child: _failed
                ? Text(
                    l10n.notifLoadFailed,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: context.zc.soft),
                  )
                : const CircularProgressIndicator(color: AppColors.red),
          ),
        ),
      );
    } else {
      children.addAll([
        toggle(
          'transfers',
          l10n.notifTransfers,
          l10n.notifTransfersHelp,
          Icons.swap_horiz_rounded,
        ),
        toggle(
          'commissions',
          l10n.notifCommissions,
          l10n.notifCommissionsHelp,
          Icons.savings_rounded,
        ),
        toggle(
          'news',
          l10n.notifNews,
          l10n.notifNewsHelp,
          Icons.campaign_rounded,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.notifSoon,
          style: TextStyle(fontSize: 13, height: 1.4, color: context.zc.soft),
        ),
      ]);
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
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
