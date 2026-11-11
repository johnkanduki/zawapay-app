import 'package:flutter/material.dart';

import '../../core/account/account_error.dart';
import '../../core/account/social_sign_in.dart';
import '../../core/account/zawapay_account.dart';
import '../../core/widgets/top_notice.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_screen.dart';
import 'screens/social_join_screen.dart';

/// The home page of the signed-in member. It follows the account: the
/// photo appears once downloaded, new numbers show at once.
Widget homeFor(SignedIn signedIn) => ValueListenableBuilder<SignedIn?>(
  valueListenable: zawapayAccount.current,
  builder: (context, now, _) {
    final s = now ?? signedIn;
    return ValueListenableBuilder<String?>(
      valueListenable: zawapayAccount.photo,
      builder: (context, photo, _) => HomeScreen(
        firstName: s.firstName,
        lastName: s.lastName,
        username: s.member.handle,
        email: s.email,
        countryCode: s.member.country,
        photoPath: photo ?? s.photoPath,
        certified: s.member.certified,
        // Withdrawals and transfers received: ONLY the withdrawal number.
        withdrawPhone: s.member.receivePhone,
        paymentPhone: s.member.paymentPhone,
      ),
    );
  },
);

/// The home page replaces every sign-in / sign-up screen.
void openHome(BuildContext context, SignedIn signedIn) => Navigator.of(context)
    .pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => homeFor(signedIn)),
      (_) => false,
    );

/// After a sign-in (password, or new password): reads the membership and
/// opens the home page. An OMINIMUM account that never joined Zawapay App
/// is signed out again, with a short explanation.
Future<void> finishSignIn(BuildContext context) async {
  final member = await zawapayAccount.me();
  if (!context.mounted) return;
  if (member == null) {
    final message = AppLocalizations.of(context).notMemberYet;
    await zawapayAccount.signOut();
    if (context.mounted) {
      showTopNotice(context, message, icon: Icons.info_rounded);
    }
    return;
  }
  final signedIn = await zawapayAccount.remember(member);
  if (context.mounted) openHome(context, signedIn);
}

/// "Continue with Google" / "Continue with Apple", on the sign-in page: a
/// member goes to the home page; someone new gives the sponsor invitation,
/// numbers and photo first. Returns once the next page is open.
Future<void> continueWith(BuildContext context, {required bool google}) async {
  final soon = AppLocalizations.of(context).contactSoon;
  if (google && !googleReady) {
    showTopNotice(context, soon, icon: Icons.info_rounded);
    return;
  }
  try {
    if (google) {
      final token = await socialSignIn.googleIdToken();
      if (token == null) return; // Closed by the person.
      await zawapayAccount.signInWithGoogle(token);
    } else {
      final apple = await socialSignIn.apple();
      if (apple == null) return;
      await zawapayAccount.signInWithApple(
        identityToken: apple.identityToken,
        rawNonce: apple.rawNonce,
        firstName: apple.firstName,
        lastName: apple.lastName,
      );
    }
    final member = await zawapayAccount.me();
    if (!context.mounted) return;
    if (member != null) {
      final signedIn = await zawapayAccount.remember(member);
      if (context.mounted) openHome(context, signedIn);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SocialJoinScreen(
          firstName: zawapayAccount.firstName,
          lastName: zawapayAccount.lastName,
        ),
      ),
    );
  } catch (error) {
    if (context.mounted) showAccountError(context, error);
  }
}
