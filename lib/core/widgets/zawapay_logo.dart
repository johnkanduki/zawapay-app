import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Temporary Zawapay App logo, drawn in code so it can be replaced later:
/// a red rounded square with a bold white "Z" whose middle stroke is an
/// arrow going up and to the right (money on its way).
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
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: CustomPaint(painter: const ZawapayZPainter()),
    );
  }
}

/// The white "Z" with its arrow (drawn on the red square).
class ZawapayZPainter extends CustomPainter {
  const ZawapayZPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final paint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Top bar, diagonal, bottom bar of the "Z".
    final z = Path()
      ..moveTo(s * 0.3, s * 0.3)
      ..lineTo(s * 0.7, s * 0.3)
      ..lineTo(s * 0.3, s * 0.7)
      ..lineTo(s * 0.7, s * 0.7);
    canvas.drawPath(z, paint);

    // Small arrow head on the top right corner of the diagonal.
    final head = Path()
      ..moveTo(s * 0.56, s * 0.3)
      ..lineTo(s * 0.7, s * 0.3)
      ..lineTo(s * 0.7, s * 0.44);
    canvas.drawPath(head, paint..strokeWidth = s * 0.12);
  }

  @override
  bool shouldRepaint(ZawapayZPainter oldDelegate) => false;
}
