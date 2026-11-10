import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/zawapay_logo.dart';

/// Zawapay QR code: round dots, round corner eyes, and a clean empty square
/// around the logo in the middle (no dot touches it).
///
/// Uses the highest error correction, so the empty middle never stops the
/// code from being read.
class ZawapayQr extends StatelessWidget {
  const ZawapayQr({super.key, required this.data, required this.size});

  final String data;
  final double size;

  /// Share of the code width left empty in the middle (logo + margin).
  static const double clearShare = 0.26;

  @override
  Widget build(BuildContext context) {
    final image = QrImage(
      QrCode.fromData(data: data, errorCorrectLevel: QrErrorCorrectLevel.H),
    );

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: ZawapayQrPainter(image),
          ),
          // The logo sits inside the empty square, with space all around.
          ZawapayLogo(size: size * clearShare * 0.72),
        ],
      ),
    );
  }
}

/// Paints the QR dots and eyes (with the empty middle).
class ZawapayQrPainter extends CustomPainter {
  ZawapayQrPainter(this.image);

  final QrImage image;

  @override
  void paint(Canvas canvas, Size size) {
    final n = image.moduleCount;
    final cell = size.width / n;
    final dark = Paint()..color = AppColors.black;

    // Empty middle, on whole modules, kept odd so it stays centred.
    var clear = (n * ZawapayQr.clearShare).round();
    if (clear.isEven) clear += 1;
    final from = (n - clear) ~/ 2;
    final to = from + clear;

    bool inEye(int r, int c) =>
        (r < 7 && c < 7) || (r < 7 && c >= n - 7) || (r >= n - 7 && c < 7);

    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (inEye(r, c)) continue;
        if (r >= from && r < to && c >= from && c < to) continue;
        if (!image.isDark(r, c)) continue;
        canvas.drawCircle(
          Offset((c + 0.5) * cell, (r + 0.5) * cell),
          cell * 0.44,
          dark,
        );
      }
    }

    // Three round eyes: a ring and a dot.
    void eye(int r, int c) {
      final center = Offset((c + 3.5) * cell, (r + 3.5) * cell);
      canvas
        ..drawCircle(
          center,
          cell * 3,
          Paint()
            ..color = AppColors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = cell,
        )
        ..drawCircle(center, cell * 1.5, dark);
    }

    eye(0, 0);
    eye(0, n - 7);
    eye(n - 7, 0);
  }

  @override
  bool shouldRepaint(ZawapayQrPainter old) => old.image != image;
}
