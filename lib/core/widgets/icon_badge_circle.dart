import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/zawapay_colors.dart';

/// Line icon inside a light grey ring, with a small red badge at the bottom right.
class IconBadgeCircle extends StatelessWidget {
  const IconBadgeCircle({
    super.key,
    required this.icon,
    required this.badge,
    this.size = 260,
  });

  final IconData icon;

  /// Content of the red badge (an icon or a short text), drawn in white.
  final Widget badge;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ring = size * 0.17;
    final badgeSize = size * 0.235;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.zc.raised,
              border: Border.all(color: context.zc.field, width: ring),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: size * 0.34, color: context.zc.text),
          ),
          Positioned(
            right: size * 0.105,
            bottom: size * 0.105,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.red,
                border: Border.all(color: AppColors.white, width: size * 0.016),
              ),
              alignment: Alignment.center,
              child: IconTheme(
                data: IconThemeData(
                  color: AppColors.white,
                  size: badgeSize * 0.45,
                ),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: context.zc.raised,
                    fontWeight: FontWeight.w800,
                    fontSize: badgeSize * 0.3,
                  ),
                  child: badge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
