import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Colours and small pieces shared by the dark "Send" pages.
abstract final class SendColors {
  /// Outer frame of a card.
  static const Color frame = Color(0x0FFFFFFF);

  /// Inside of a card, and the fields.
  static const Color card = Color(0x14FFFFFF);
  static const Color field = Color(0x1FFFFFFF);
  static const Color soft = Color(0x99FFFFFF);
}

/// Round dark button (back, close, edit…).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 54,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: SendColors.field,
        ),
        child: Icon(icon, color: AppColors.white),
      ),
    );
  }
}

/// Rounded card with a thin outer frame, as on the reference pages.
class FramedCard extends StatelessWidget {
  const FramedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: SendColors.frame),
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: SendColors.card,
          borderRadius: BorderRadius.circular(30),
        ),
        child: child,
      ),
    );
  }
}
