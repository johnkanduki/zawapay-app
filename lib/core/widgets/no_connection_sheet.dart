import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'app_bottom_sheet.dart';
import 'app_buttons.dart';
import 'icon_badge_circle.dart';

/// Sheet shown when the phone has no internet connection.
/// Not yet triggered automatically: it will be wired when network calls exist.
Future<void> showNoConnectionSheet(
  BuildContext context, {
  VoidCallback? onRetry,
}) {
  return showAppBottomSheet<void>(
    context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const IconBadgeCircle(
            icon: Icons.wifi_rounded,
            badge: Icon(Icons.wifi_off_rounded),
            size: 180,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noConnectionTitle,
            textAlign: TextAlign.center,
            style: AppText.screenTitle(context).copyWith(fontSize: 26),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.noConnectionBody,
            textAlign: TextAlign.center,
            style: AppText.body(context).copyWith(fontSize: 17),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: l10n.retry,
            onPressed: () {
              Navigator.of(context).pop();
              onRetry?.call();
            },
          ),
        ],
      );
    },
  );
}
