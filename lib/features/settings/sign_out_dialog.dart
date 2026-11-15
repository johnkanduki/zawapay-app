import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../l10n/app_localizations.dart';

/// "Sign out of Zawapay App?": dark rounded card in the middle of the screen,
/// red "Sign out" and grey "Cancel". True when the user confirms.
Future<bool> confirmSignOut(BuildContext context) => _confirm(
  context,
  (l10n) => (l10n.signOutTitle, l10n.signOutBody, l10n.signOutConfirm),
);

/// "Delete your account?": the same card, with what is erased and kept.
Future<bool> confirmDeleteAccount(BuildContext context) => _confirm(
  context,
  (l10n) => (
    l10n.deleteAccountTitle,
    l10n.deleteAccountBody,
    l10n.deleteAccountConfirm,
  ),
);

Future<bool> _confirm(
  BuildContext context,
  (String, String, String) Function(AppLocalizations l10n) texts,
) async {
  final yes = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x99000000),
    builder: (_) => _ConfirmDialog(texts: texts),
  );
  return yes ?? false;
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({required this.texts});

  final (String, String, String) Function(AppLocalizations l10n) texts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (title, body, confirm) = texts(l10n);

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
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.zc.text,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              body,
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
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(confirm),
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
                    fontFamily: 'PlusJakartaSans',
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
