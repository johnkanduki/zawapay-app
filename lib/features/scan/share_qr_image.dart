import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/zawapay_logo.dart';
import 'zawapay_qr.dart';

/// Draws the share image of a payment code and saves it as a PNG file:
/// white card, "Zawapay App", the QR code with the logo in its empty middle,
/// the "@" under it and "Scan to pay".
///
/// Big and sharp on purpose, so it still scans after WhatsApp or Facebook
/// compress it.
Future<File> buildShareQrImage({
  required String data,
  required String handle,
  required String scanLabel,
  String? amountLabel,
}) async {
  const width = 1080.0;
  const height = 1350.0;
  const qrSide = 760.0;
  const qrLeft = (width - qrSide) / 2;
  const qrTop = 250.0;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  canvas.drawRect(
    const Rect.fromLTWH(0, 0, width, height),
    Paint()..color = AppColors.white,
  );

  // "Zawapay App" with the small logo, at the top.
  const logo = 84.0;
  _text(
    canvas,
    'Zawapay App',
    52,
    FontWeight.w700,
    AppColors.black,
    const Offset(width / 2 + logo / 2 + 14, 120),
    center: true,
  );
  _logo(canvas, const Rect.fromLTWH(width / 2 - 250, 78, logo, logo));

  // The QR code (same drawing as in the app), logo in the empty middle.
  final image = QrImage(
    QrCode.fromData(data: data, errorCorrectLevel: QrErrorCorrectLevel.H),
  );
  canvas.save();
  canvas.translate(qrLeft, qrTop);
  ZawapayQrPainter(image).paint(canvas, const Size.square(qrSide));
  canvas.restore();
  const middle = qrSide * ZawapayQr.clearShare * 0.72;
  _logo(
    canvas,
    Rect.fromCenter(
      center: const Offset(width / 2, qrTop + qrSide / 2),
      width: middle,
      height: middle,
    ),
  );

  _text(
    canvas,
    handle,
    58,
    FontWeight.w700,
    AppColors.black,
    const Offset(width / 2, qrTop + qrSide + 110),
    center: true,
  );
  // The amount asked for, in a red pill, instead of "Scan to pay".
  if (amountLabel != null) {
    final pill = Rect.fromCenter(
      center: const Offset(width / 2, qrTop + qrSide + 235),
      width: 120 + amountLabel.length * 30,
      height: 92,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pill, const Radius.circular(46)),
      Paint()..color = AppColors.red,
    );
    _text(
      canvas,
      amountLabel,
      50,
      FontWeight.w700,
      AppColors.white,
      pill.center,
      center: true,
    );
  } else {
    _text(
      canvas,
      scanLabel,
      40,
      FontWeight.w500,
      AppColors.grey,
      const Offset(width / 2, qrTop + qrSide + 185),
      center: true,
    );
  }

  final picture = recorder.endRecording();
  final rendered = await picture.toImage(width.toInt(), height.toInt());
  final png = await rendered.toByteData(format: ui.ImageByteFormat.png);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/zawapay_${handle.replaceAll('@', '')}.png');
  await file.writeAsBytes(png!.buffer.asUint8List(), flush: true);
  return file;
}

void _logo(Canvas canvas, Rect rect) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.28)),
    Paint()..color = AppColors.red,
  );
  canvas.save();
  canvas.translate(rect.left, rect.top);
  const ZawapayZPainter().paint(canvas, rect.size);
  canvas.restore();
}

void _text(
  Canvas canvas,
  String text,
  double size,
  FontWeight weight,
  Color color,
  Offset at, {
  bool center = false,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: weight,
        color: color,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final offset = center
      ? at - Offset(painter.width / 2, painter.height / 2)
      : at;
  painter.paint(canvas, offset);
}
