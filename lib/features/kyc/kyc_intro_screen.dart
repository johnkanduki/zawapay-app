import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/verified_badge.dart';
import '../../l10n/app_localizations.dart';

/// Opened from the home page when the account is not certified yet.
///
/// Explains the identity check (KYC) that certifies the user's "@" username
/// with the blue badge, and the three steps. The steps themselves are not
/// built yet: "Start" does nothing for now.
class KycIntroScreen extends StatelessWidget {
  const KycIntroScreen({
    super.key,
    required this.fullName,
    required this.username,
    this.photoPath,
  });

  final String fullName;
  final String username;
  final String? photoPath;

  static const Color _card = Color(0x14FFFFFF);
  static const Color _soft = Color(0x99FFFFFF);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final handle = username.isEmpty ? '' : '@$username';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    const Center(child: _BadgeHalo()),
                    const SizedBox(height: 26),
                    Text(
                      l10n.kycTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.kycSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        color: _soft,
                      ),
                    ),
                    const SizedBox(height: 26),
                    // How the profile will look once certified.
                    _ProfilePreview(
                      fullName: fullName,
                      handle: handle,
                      photoPath: photoPath,
                    ),
                    const SizedBox(height: 26),
                    _Step(
                      number: 1,
                      icon: Icons.badge_outlined,
                      title: l10n.kycStepIdTitle,
                      body: l10n.kycStepIdBody,
                    ),
                    _Step(
                      number: 2,
                      icon: Icons.face_retouching_natural_outlined,
                      title: l10n.kycStepSelfieTitle,
                      body: l10n.kycStepSelfieBody,
                    ),
                    _Step(
                      number: 3,
                      icon: Icons.verified_user_outlined,
                      title: l10n.kycStepReviewTitle,
                      body: l10n.kycStepReviewBody,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                          color: _soft,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.kycPrivacy,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: _soft,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: PrimaryButton(label: l10n.kycStart, onPressed: () {}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Big blue badge with a soft blue glow around it.
class _BadgeHalo extends StatelessWidget {
  const _BadgeHalo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.verified.withValues(alpha: 0.12),
        boxShadow: [
          BoxShadow(
            color: AppColors.verified.withValues(alpha: 0.35),
            blurRadius: 50,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const VerifiedBadge(size: 68),
    );
  }
}

class _ProfilePreview extends StatelessWidget {
  const _ProfilePreview({
    required this.fullName,
    required this.handle,
    required this.photoPath,
  });

  final String fullName;
  final String handle;
  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    final photo = photoPath;
    final initial = fullName.isEmpty
        ? ''
        : fullName.characters.first.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KycIntroScreen._card,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox.square(
              dimension: 52,
              child: photo != null
                  ? Image.file(File(photo), fit: BoxFit.cover)
                  : ColoredBox(
                      color: KycIntroScreen._card,
                      child: Center(
                        child: initial.isEmpty
                            ? const Icon(
                                Icons.person_rounded,
                                color: AppColors.red,
                              )
                            : Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.red,
                                ),
                              ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fullName.isNotEmpty)
                  Text(
                    fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                if (handle.isNotEmpty)
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          handle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: KycIntroScreen._soft,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const VerifiedBadge(size: 17),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.icon,
    required this.title,
    required this.body,
  });

  final int number;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: KycIntroScreen._card,
            ),
            child: Icon(icon, color: AppColors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number. $title',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: KycIntroScreen._soft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0x1FFFFFFF),
        ),
        child: Icon(icon, color: AppColors.white),
      ),
    );
  }
}
