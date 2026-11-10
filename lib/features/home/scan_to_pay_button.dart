import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// "Scan to pay" on the right of the home header: a red rounded square with
/// the scan mark drawn in code, and a short label on the "@" line.
class ScanToPayButton extends StatelessWidget {
  const ScanToPayButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      label: l10n.scanToPay,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: const ScanMark(size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.scanToPay,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Four rounded corners and a line through the middle (white).
class ScanMark extends StatelessWidget {
  const ScanMark({super.key, this.size = 24, this.color = AppColors.white});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _ScanMarkPainter(color));
}

class _ScanMarkPainter extends CustomPainter {
  const _ScanMarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = s * 0.1;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final inset = stroke / 2;
    final arm = s * 0.3; // length of each corner arm
    final r = s * 0.16; // corner roundness
    final l = inset, t = inset, rt = s - inset, b = s - inset;

    Path corner(Offset start, Offset bend, Offset end) {
      return Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(
          bend.dx + (start.dx - bend.dx).sign * r,
          bend.dy + (start.dy - bend.dy).sign * r,
        )
        ..quadraticBezierTo(
          bend.dx,
          bend.dy,
          bend.dx + (end.dx - bend.dx).sign * r,
          bend.dy + (end.dy - bend.dy).sign * r,
        )
        ..lineTo(end.dx, end.dy);
    }

    canvas
      ..drawPath(
        corner(Offset(l, t + arm), Offset(l, t), Offset(l + arm, t)),
        paint,
      )
      ..drawPath(
        corner(Offset(rt - arm, t), Offset(rt, t), Offset(rt, t + arm)),
        paint,
      )
      ..drawPath(
        corner(Offset(rt, b - arm), Offset(rt, b), Offset(rt - arm, b)),
        paint,
      )
      ..drawPath(
        corner(Offset(l + arm, b), Offset(l, b), Offset(l, b - arm)),
        paint,
      )
      // The scan line, a little shorter than the frame.
      ..drawLine(Offset(s * 0.12, s / 2), Offset(s * 0.88, s / 2), paint);
  }

  @override
  bool shouldRepaint(_ScanMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
