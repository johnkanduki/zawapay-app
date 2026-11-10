import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../send/recipient.dart';
import 'transfer.dart';

const Color _circle = Color(0x14FFFFFF);

/// One line of the history: status in a circle, the other person's "@"
/// (badge), the status, and the signed amount with when it happened.
/// Same line on the home page and on the full history page.
class TransferRow extends StatelessWidget {
  const TransferRow({super.key, required this.transfer, required this.onTap});

  final Transfer transfer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, status) = switch (transfer.status) {
      TransferStatus.success => (Icons.check_rounded, l10n.statusSuccess),
      TransferStatus.pending => (Icons.schedule_rounded, l10n.statusPending),
      TransferStatus.failed => (Icons.close_rounded, l10n.statusFailed),
    };
    final when = transfer.daysAgo >= 30
        ? l10n.monthsAgo((transfer.daysAgo / 30).round())
        : l10n.daysAgo(transfer.daysAgo);
    const grey = Color(0x99FFFFFF);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 6, 22, 6),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: transfer.status == TransferStatus.success
                    ? AppColors.white
                    : AppColors.red,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The other person, by "@" (with the blue badge).
                  RecipientHandle(recipient: transfer.other, fontSize: 15),
                  Text(
                    status,
                    style: const TextStyle(fontSize: 15, color: grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transfer.signedAmount(locale),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    when,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 13, color: grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
