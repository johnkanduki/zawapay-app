import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/top_notice.dart';
import 'zawapay_account.dart';

/// Short text for a failed server call: the server message in French,
/// otherwise a general message in the app language.
String accountErrorText(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context);
  if (error is AccountException) {
    if (error.isNetwork) return l10n.errorNetwork;
    final french = Localizations.localeOf(context).languageCode == 'fr';
    if (french && error.message.isNotEmpty) return error.message;
  }
  return l10n.errorGeneric;
}

/// Shows the error at the top of the screen.
void showAccountError(BuildContext context, Object error) => showTopNotice(
  context,
  accountErrorText(context, error),
  icon: Icons.error_rounded,
);
