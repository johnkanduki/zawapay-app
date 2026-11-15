// Draws the app icon images from the same painter as the in-app logo.
// Run: flutter test tool/app_icon_test.dart  → PNGs in build/app_icon/.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/theme/app_colors.dart';
import 'package:zawapay_app/core/widgets/zawapay_logo.dart';

Future<void> _save(
  String name,
  int px, {
  Color? background,
  double radius = 0,
  double zScale = 1,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final s = px.toDouble();
  if (background != null) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & Size(s, s),
        Radius.circular(radius * s),
      ),
      Paint()..color = background,
    );
  }
  // The Z, centred, scaled down for the Android safe zone if asked.
  final z = s * zScale;
  canvas.translate((s - z) / 2, (s - z) / 2);
  const ZawapayZPainter().paint(canvas, Size(z, z));
  final image = await recorder.endRecording().toImage(px, px);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File('build/app_icon/$name.png')..createSync(recursive: true);
  file.writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('app icon images', () async {
    // iOS and stores: full square, opaque (the system rounds the corners).
    await _save('square_1024', 1024, background: AppColors.red);
    // Android before 8: rounded square on transparent.
    await _save('legacy_512', 512, background: AppColors.red, radius: 0.225);
    // Android 8+ (adaptive): the Z alone, inside the 66/108 safe zone.
    await _save('foreground_432', 432, zScale: 66 / 108);
  });
}
