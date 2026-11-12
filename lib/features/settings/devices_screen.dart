import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/account/account_error.dart';
import '../../core/account/zawapay_account.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/top_notice.dart';
import '../../l10n/app_localizations.dart';
import '../send/send_ui.dart';

/// The server calls of this page; tests replace them.
Future<List<Map<String, dynamic>>> Function() loadDevices =
    zawapayAccount.devices;
Future<void> Function(String id) signOutDevice = zawapayAccount.revokeDevice;

/// Settings → Security → « Appareils connectés »: the phones signed in to
/// the account (this one marked), each other one can be signed out.
class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<Map<String, dynamic>>? _devices;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await loadDevices();
      if (mounted) setState(() => (_devices = list, _failed = false));
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _signOut(Map<String, dynamic> device) async {
    final l10n = AppLocalizations.of(context);
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        content: Text(l10n.devicesConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.devicesCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(
              l10n.devicesSignOut,
              style: const TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    try {
      await signOutDevice('${device['id']}');
      if (mounted) showTopNotice(context, l10n.devicesDone);
      await _load();
    } catch (error) {
      if (mounted) showAccountError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final devices = _devices;

    final children = <Widget>[
      Row(
        children: [
          RoundIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 14),
          Text(
            l10n.devicesTitle,
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
        l10n.devicesIntro,
        style: TextStyle(fontSize: 15, height: 1.4, color: context.zc.soft),
      ),
      const SizedBox(height: 16),
    ];
    if (devices == null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Center(
            child: _failed
                ? Text(
                    l10n.devicesLoadFailed,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: context.zc.soft),
                  )
                : const CircularProgressIndicator(color: AppColors.red),
          ),
        ),
      );
    } else {
      for (final d in devices) {
        final current = d['current'] == true;
        final since = DateTime.tryParse('${d['since']}')?.toLocal();
        children.add(
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            decoration: BoxDecoration(
              color: context.zc.card,
              borderRadius: BorderRadius.circular(22),
              border: current
                  ? Border.all(color: const Color(0xFF1E9E5A), width: 1.5)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.phone_iphone_rounded,
                  size: 30,
                  color: context.zc.text,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${d['name']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.zc.text,
                        ),
                      ),
                      if (since != null)
                        Text(
                          l10n.devicesSince(
                            DateFormat.yMMMd(locale).format(since),
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: context.zc.soft,
                          ),
                        ),
                      if (current)
                        Text(
                          l10n.devicesThis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E9E5A),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!current)
                  TextButton(
                    onPressed: () => _signOut(d),
                    child: Text(
                      l10n.devicesSignOut,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }
      if (devices.where((d) => d['current'] != true).isEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l10n.devicesEmpty,
              style: TextStyle(fontSize: 14, color: context.zc.soft),
            ),
          ),
        );
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
