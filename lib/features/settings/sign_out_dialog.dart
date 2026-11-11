import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../l10n/app_localizations.dart';

/// "Sign out of Zawapay App?": dark rounded card in the middle of the screen,
/// red "Sign out" and grey "Cancel". True when the user confirms.
Future<bool> confirmSignOut(BuildContext context) async {
  final yes = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x99000000),
    builder: (_) => const _SignOutDialog(),
  );
  return yes ?? false;
}

class _SignOutDialog extends StatelessWidget {
  const _SignOutDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: context.zc.isDark
          ? const Color(0xFF232325)
          : context.zc.raised,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 30, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.signOutTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.zc.text,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.signOutBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: context.zc.soft,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: AppColors.white,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(l10n.signOutConfirm),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: FilledButton.styleFrom(
                  backgroundColor: context.zc.field,
                  foregroundColor: context.zc.text,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(l10n.cancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
