import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The Zawapay App logo (same as the app icon): a red rounded square with
/// a white "Z" going both ways — sending and receiving.
class ZawapayLogo extends StatelessWidget {
  const ZawapayLogo({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(size * 0.225),
      ),
      child: CustomPaint(painter: const ZawapayZPainter()),
    );
  }
}

/// The white "Z" going both ways (drawn on the red square): the top bar
/// is an arrow to the right (sending), the bottom bar an arrow to the left
/// (receiving), joined by the diagonal. Drawn on a 120-unit grid.
class ZawapayZPainter extends CustomPainter {
  const ZawapayZPainter({this.color = AppColors.white});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 120;
    Offset p(double x, double y) => Offset(x * u, y * u);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12 * u
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Top bar, diagonal, bottom bar.
    canvas.drawPath(
      Path()
        ..moveTo(p(34, 38).dx, p(34, 38).dy)
        ..lineTo(p(82, 38).dx, p(82, 38).dy)
        ..moveTo(p(86, 82).dx, p(86, 82).dy)
        ..lineTo(p(38, 82).dx, p(38, 82).dy)
        ..moveTo(p(82, 38).dx, p(82, 38).dy)
        ..lineTo(p(38, 82).dx, p(38, 82).dy),
      paint,
    );
    // Arrow heads: to the right on top, to the left at the bottom.
    paint.strokeWidth = 10 * u;
    canvas.drawPath(
      Path()
        ..moveTo(p(72, 28).dx, p(72, 28).dy)
        ..lineTo(p(84, 38).dx, p(84, 38).dy)
        ..lineTo(p(72, 48).dx, p(72, 48).dy)
        ..moveTo(p(48, 72).dx, p(48, 72).dy)
        ..lineTo(p(36, 82).dx, p(36, 82).dy)
        ..lineTo(p(48, 92).dx, p(48, 92).dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(ZawapayZPainter oldDelegate) => oldDelegate.color != color;
}
