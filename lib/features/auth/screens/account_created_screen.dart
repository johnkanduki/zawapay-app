import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/zawapay_colors.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/icon_badge_circle.dart';
import '../../../l10n/app_localizations.dart';
import '../../onboarding/onboarding_screen.dart';
import 'sign_in_screen.dart';

/// After a sign-up by e-mail: the account is created, and the person signs
/// in by themself (identifier or e-mail, and password). No way back into
/// the sign-up pages.
class AccountCreatedScreen extends StatelessWidget {
  const AccountCreatedScreen({super.key});

  void _signIn(BuildContext context) {
    final navigator = Navigator.of(context);
    // Back from the sign-in page leads to the first page, never to black.
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (_) => false,
    );
    navigator.push(MaterialPageRoute(builder: (_) => const SignInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.zc.page,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const IconBadgeCircle(
                    icon: Icons.mark_email_read_outlined,
                    badge: Icon(Icons.check_rounded),
                    size: 180,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    l10n.accountCreatedTitle,
                    textAlign: TextAlign.center,
                    style: AppText.screenTitle(context).copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.accountCreatedBody,
                    textAlign: TextAlign.center,
                    style: AppText.body(context)
                        .copyWith(fontSize: 17, color: context.zc.soft),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: l10n.accountCreatedSignIn,
                    onPressed: () => _signIn(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
