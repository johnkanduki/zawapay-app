import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Google "G" drawn in Google's own brand colours (allowed: third-party logo).
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _GooglePainter());
  }
}

class _GooglePainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.22;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    Paint arc(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    const deg = math.pi / 180;
    canvas.drawArc(rect, -40 * deg, -100 * deg, false, arc(_red));
    canvas.drawArc(rect, -140 * deg, -90 * deg, false, arc(_yellow));
    canvas.drawArc(rect, -230 * deg, -95 * deg, false, arc(_green));
    canvas.drawArc(rect, -325 * deg, -35 * deg, false, arc(_blue));

    final barTop = size.height / 2 - stroke / 2;
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / 2,
        barTop,
        size.width / 2 - stroke / 2 + stroke / 2,
        stroke,
      ),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
