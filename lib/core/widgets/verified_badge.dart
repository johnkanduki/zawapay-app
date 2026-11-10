import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Blue certification badge, drawn in code: a rounded, scalloped rosette
/// with a white check. Shown next to a certified (KYC) username.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'verified',
      child: CustomPaint(
        size: Size.square(size),
        painter: const _BadgePainter(),
      ),
    );
  }
}

class _BadgePainter extends CustomPainter {
  const _BadgePainter();

  /// Number of rounded points around the rosette.
  static const int _points = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = size.width / 2;
    final inner = outer * 0.80;

    // Rosette: each point is a curve that bulges out to the outer radius.
    final rosette = Path();
    const step = math.pi / _points;
    for (var i = 0; i < _points * 2; i++) {
      final angle = -math.pi / 2 + i * step;
      final isPoint = i.isEven;
      final radius = isPoint ? outer * 1.04 : inner;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (i == 0) {
        final start =
            center +
            Offset(math.cos(angle - step), math.sin(angle - step)) * inner;
        rosette.moveTo(start.dx, start.dy);
      }
      if (isPoint) {
        final next =
            center +
            Offset(math.cos(angle + step), math.sin(angle + step)) * inner;
        rosette.quadraticBezierTo(point.dx, point.dy, next.dx, next.dy);
      }
    }
    rosette.close();
    canvas.drawPath(
      rosette,
      Paint()
        ..color = AppColors.verified
        ..isAntiAlias = true,
    );

    // White check mark.
    final s = size.width;
    final check = Path()
      ..moveTo(s * 0.29, s * 0.52)
      ..lineTo(s * 0.44, s * 0.66)
      ..lineTo(s * 0.72, s * 0.37);
    canvas.drawPath(
      check,
      Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.11
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_BadgePainter oldDelegate) => false;
}
