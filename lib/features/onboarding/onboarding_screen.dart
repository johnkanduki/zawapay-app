import 'package:flutter/material.dart';

import '../../core/theme/zawapay_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/underlined_link.dart';
import '../../l10n/app_localizations.dart';
import '../auth/screens/sign_in_screen.dart';
import '../auth/screens/sign_up_screen.dart';

/// First screen: a full illustration at the top, and a white panel with
/// rounded top corners that slides up from the bottom over the image,
/// holding "Sign in" / "Create an account".
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const _heroImage = 'assets/images/onboarding_hero.jpg';

  /// How much the panel covers the bottom of the image.
  static const double _panelOverlap = 36;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.zc.raised,
      body: Column(
        children: [
          // The image fills the space above the panel and runs a little
          // under it, so the rounded corners sit on top of the image.
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: -_panelOverlap,
                  child: Image.asset(
                    _heroImage,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ],
            ),
          ),
          const _SlideUp(child: _ActionsPanel()),
        ],
      ),
    );
  }
}

/// Slides its child up from below the screen when the page opens.
class _SlideUp extends StatelessWidget {
  const _SlideUp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, offset, child) =>
          FractionalTranslation(translation: Offset(0, offset), child: child),
    );
  }
}

/// White panel with rounded top corners holding the two entry buttons.
class _ActionsPanel extends StatelessWidget {
  const _ActionsPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
      decoration: BoxDecoration(
        color: context.zc.raised,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(OnboardingScreen._panelOverlap),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              label: l10n.signIn,
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SignInScreen())),
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: l10n.createAccount,
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SignUpScreen())),
            ),
            const SizedBox(height: 24),
            Text.rich(
              TextSpan(
                style: AppText.body(context).copyWith(fontSize: 15),
                children: [
                  TextSpan(text: l10n.legalPrefix),
                  linkSpan(l10n.legalTerms, () {}, fontSize: 15),
                  TextSpan(text: l10n.legalAnd),
                  linkSpan(l10n.legalPrivacy, () {}, fontSize: 15),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
