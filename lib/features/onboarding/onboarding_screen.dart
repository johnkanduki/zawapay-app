import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/icon_badge_circle.dart';
import '../../core/widgets/underlined_link.dart';
import '../../l10n/app_localizations.dart';
import '../auth/screens/sign_in_screen.dart';
import '../auth/screens/sign_up_screen.dart';

/// First screen: 3 swipeable slides, then "Sign in" / "Create an account".
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = [
      (
        Icons.send_outlined,
        const Icon(Icons.public_rounded),
        l10n.onboardingTitle1,
      ),
      (
        Icons.account_balance_wallet_outlined,
        const Icon(Icons.shield_outlined),
        l10n.onboardingTitle2,
      ),
      (
        Icons.group_outlined,
        const Icon(Icons.add_rounded),
        l10n.onboardingTitle3,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _page = page),
                  children: [
                    for (final (icon, badge, title) in slides)
                      _Slide(icon: icon, badge: badge, title: title),
                  ],
                ),
              ),
              _PageDots(count: slides.length, current: _page),
              const SizedBox(height: 44),
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
                  style: AppText.body.copyWith(fontSize: 15),
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
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.icon, required this.badge, required this.title});

  final IconData icon;
  final Widget badge;
  final String title;

  @override
  Widget build(BuildContext context) {
    // Shrinks on small screens so the title always fits.
    return LayoutBuilder(
      builder: (context, constraints) => FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          children: [
            const SizedBox(height: 24),
            IconBadgeCircle(icon: icon, badge: badge),
            const SizedBox(height: 48),
            SizedBox(
              width: constraints.maxWidth,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppText.heroTitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Red pill for the current slide, light grey dots for the others.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == current ? 32 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: i == current ? AppColors.red : AppColors.surface,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
      ],
    );
  }
}
