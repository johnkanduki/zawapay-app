import 'package:flutter/material.dart';

import '../../core/theme/zawapay_colors.dart';

/// Fixed dark colours, kept only for pages that stay dark in both modes
/// (camera). Other pages use `context.zc` (light / dark).
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
        // White with a thin line in light mode: visible on the grey page
        // and inside white cards alike.
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.zc.isDark ? context.zc.field : context.zc.raised,
          border: context.zc.isDark ? null : Border.all(color: context.zc.line),
        ),
        child: Icon(icon, color: context.zc.text),
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
        border: Border.all(color: context.zc.frame),
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: context.zc.card,
          borderRadius: BorderRadius.circular(30),
        ),
        child: child,
      ),
    );
  }
}
