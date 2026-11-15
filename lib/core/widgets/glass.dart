import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/zawapay_colors.dart';

/// Frosted glass, like iOS: what passes behind is blurred, a light tint on
/// top, a soft reflection from the top edge and a thin bright outline.
/// [tint] colours the glass (red for a main button); null = neutral glass.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.shape = const StadiumBorder(),
    this.tint,
    this.blur = 22,
    this.shadow = false,
  });

  final Widget child;
  final ShapeBorder shape;
  final Color? tint;
  final double blur;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final dark = context.zc.isDark;
    final base =
        tint ??
        (dark ? const Color(0xFF2A2A2D) : Colors.white).withValues(
          alpha: dark ? 0.66 : 0.78,
        );
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        shadows: shadow
            ? [
                // Soft and pulled in: it must not show through the glass.
                BoxShadow(
                  color: (tint ?? Colors.black).withValues(
                    alpha: tint != null ? 0.22 : (dark ? 0.30 : 0.07),
                  ),
                  blurRadius: 20,
                  spreadRadius: -6,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: shape,
              // The reflection: brighter at the top, fading downwards.
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.alphaBlend(
                    Colors.white.withValues(alpha: dark ? 0.10 : 0.30),
                    base,
                  ),
                  base,
                  Color.alphaBlend(
                    Colors.black.withValues(alpha: tint != null ? 0.06 : 0.0),
                    base,
                  ),
                ],
                stops: const [0, 0.55, 1],
              ),
            ),
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              // Thin bright outline, stronger on the top edge.
              decoration: ShapeDecoration(
                shape: _outline(
                  shape,
                  Colors.white.withValues(alpha: dark ? 0.16 : 0.75),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  static ShapeBorder _outline(ShapeBorder shape, Color color) {
    final side = BorderSide(color: color, width: 0.8);
    if (shape is StadiumBorder) return StadiumBorder(side: side);
    if (shape is RoundedRectangleBorder) {
      return RoundedRectangleBorder(
        borderRadius: shape.borderRadius,
        side: side,
      );
    }
    if (shape is CircleBorder) return CircleBorder(side: side);
    return shape;
  }
}
