import 'package:flutter/material.dart';

import '../../core/account/account_error.dart';
import '../../core/account/withdraw_pin.dart';
import '../../core/account/zawapay_account.dart';
import '../../core/widgets/top_notice.dart';
import '../../l10n/app_localizations.dart';
import '../history/my_transfers.dart';
import '../onboarding/onboarding_screen.dart';
import '../withdraw/pin_sheet.dart';
import 'sign_out_dialog.dart';

/// The server call; tests replace it.
Future<void> Function(String pin) deleteMyAccount =
    zawapayAccount.deleteAccount;

/// Settings → About → "Delete account": what is erased, then the PIN, then
/// the server deletes. Back to the first page, signed out, with a notice.
/// The server refuses while a transfer or withdrawal is in progress, or
/// while commissions can still be withdrawn: its message is shown.
Future<void> deleteAccountFlow(BuildContext context) async {
  if (!await confirmDeleteAccount(context) || !context.mounted) return;
  final pin = await askWithdrawPin(context);
  if (pin == null || !context.mounted) return;
  try {
    await deleteMyAccount(pin);
  } catch (error) {
    if (context.mounted) showAccountError(context, error);
    return;
  }
  if (!context.mounted) return;
  final done = AppLocalizations.of(context).deleteAccountDone;
  final navigator = Navigator.of(context);
  // Nothing stays on the phone.
  zawapayAccount.signOut();
  withdrawPin.forget();
  myTransfers.value = null;
  myBalanceUsd.value = 0;
  var shown = false;
  navigator.pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (page) {
        // Once, on the first page itself.
        if (!shown) {
          shown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (page.mounted) showTopNotice(page, done);
          });
        }
        return const OnboardingScreen();
      },
    ),
    (_) => false,
  );
}
