import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/countries/country.dart';
import '../../core/sound/scan_sound.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/top_notice.dart';
import '../../l10n/app_localizations.dart';
import '../send/recipient.dart';
import '../send/send_amount_screen.dart';
import '../send/send_ui.dart';
import 'my_qr_screen.dart';
import 'pay_qr.dart';
import 'recent_photos_strip.dart';

/// "Scan to pay": the back camera opens at once, with a red line moving in
/// the frame while it waits for a code. A Zawapay code opens the amount page
/// for that account. "Gallery" (bottom right) reads a code from a photo.
class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    required this.senderCountry,
    required this.me,
    this.balances = const {},
  });

  final Country senderCountry;

  /// The user, for "My QR code".
  final Recipient me;

  /// The user's Zawapay balance, to pay from it.
  final Map<String, double> balances;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final _camera = MobileScannerController(
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  late final _line = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  /// Only one code is handled at a time.
  bool _handling = false;
  String? _lastUnknown;

  @override
  void dispose() {
    _line.dispose();
    _camera.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    for (final code in capture.barcodes) {
      _handle(code.rawValue);
      if (_handling) return;
    }
  }

  Future<void> _handle(String? raw) async {
    if (_handling || raw == null) return;
    final request = PayQr.parse(raw);
    final recipient = PayQr.recipientOf(raw);
    if (recipient == null) {
      // Say it once per code, not on every camera frame.
      if (raw != _lastUnknown) {
        _lastUnknown = raw;
        showTopNotice(
          context,
          AppLocalizations.of(context).scanUnknownCode,
          icon: Icons.error_rounded,
        );
      }
      return;
    }
    _handling = true;
    // Code found: the double "ding" and two quick taps.
    ScanSound.play();
    HapticFeedback.heavyImpact();
    Future<void>.delayed(
      const Duration(milliseconds: 180),
      HapticFeedback.heavyImpact,
    );
    await _camera.stop();
    if (!mounted) return;
    await _openAmount(recipient, request);
  }

  /// Opens the amount page above the scanner, so "back" returns here; the
  /// camera then starts again, ready for another code.
  Future<void> _openAmount(Recipient recipient, PayRequest? request) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SendAmountScreen(
          recipient: recipient,
          senderCountry: widget.senderCountry,
          balances: widget.balances,
          // A code with an amount fills it in; the payer can still change it.
          initialAmount: request?.amount,
          initialCurrency: request?.currency,
        ),
      ),
    );
    if (!mounted) return;
    _handling = false;
    _lastUnknown = null;
    try {
      await _camera.start();
    } catch (_) {
      // The camera error message already covers this.
    }
  }

  Future<void> _fromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    await _fromPhoto(picked.path);
  }

  /// Reads a QR code from a photo (gallery or the recent photos row).
  Future<void> _fromPhoto(String path) async {
    final l10n = AppLocalizations.of(context);
    BarcodeCapture? capture;
    try {
      capture = await _camera.analyzeImage(
        path,
        formats: const [BarcodeFormat.qrCode],
      );
    } catch (_) {
      // Some devices (like the iOS simulator) cannot read photos.
      capture = null;
    }
    if (!mounted) return;
    final raw = capture?.barcodes.firstOrNull?.rawValue;
    if (raw == null) {
      showTopNotice(context, l10n.scanNoCodeInPhoto, icon: Icons.error_rounded);
      return;
    }
    _lastUnknown = null;
    await _handle(raw);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final frame = MediaQuery.sizeOf(context).width * 0.68;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _camera,
              onDetect: _onDetect,
              errorBuilder: (context, error) => _CameraError(
                denied:
                    error.errorCode == MobileScannerErrorCode.permissionDenied,
              ),
            ),
            // Dark veil with a clear square in the middle.
            IgnorePointer(child: CustomPaint(painter: _VeilPainter(frame))),
            Center(
              child: SizedBox.square(
                dimension: frame,
                child: AnimatedBuilder(
                  animation: _line,
                  builder: (context, _) => CustomPaint(
                    painter: _FramePainter(progress: _line.value),
                  ),
                ),
              ),
            ),
            // Hint just under the frame.
            IgnorePointer(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: frame + 70),
                  child: Text(
                    l10n.scanHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        RoundIconButton(
                          icon: Icons.close_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            l10n.scanToPay,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Latest photos, ready to tap, before even opening Gallery.
                    RecentPhotosStrip(onPicked: _fromPhoto),
                    const SizedBox(height: 14),
                    // Two buttons: my own QR code (left), a photo (right).
                    Row(
                      children: [
                        _PillButton(
                          icon: Icons.qr_code_2_rounded,
                          label: l10n.scanMyCode,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MyQrScreen(me: widget.me),
                            ),
                          ),
                        ),
                        const Spacer(),
                        _PillButton(
                          icon: Icons.photo_library_rounded,
                          label: l10n.scanGallery,
                          onTap: _fromGallery,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 20, 12),
        decoration: const ShapeDecoration(
          color: Color(0x33FFFFFF),
          shape: StadiumBorder(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
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

class _CameraError extends StatelessWidget {
  const _CameraError({required this.denied});

  final bool denied;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ColoredBox(
      color: AppColors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            denied ? l10n.cameraAccessDenied : l10n.cameraFailed,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: SendColors.soft),
          ),
        ),
      ),
    );
  }
}

/// Darkens everything except a rounded square in the middle.
class _VeilPainter extends CustomPainter {
  const _VeilPainter(this.frame);

  final double frame;

  @override
  void paint(Canvas canvas, Size size) {
    final hole = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: frame,
        height: frame,
      ),
      const Radius.circular(28),
    );
    final veil = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(hole)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(veil, Paint()..color = const Color(0x99000000));
  }

  @override
  bool shouldRepaint(_VeilPainter old) => old.frame != frame;
}

/// White corners of the frame and the red line sweeping up and down.
class _FramePainter extends CustomPainter {
  const _FramePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    const stroke = 5.0;
    const arm = 42.0;
    const r = 26.0;
    final corners = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    const h = stroke / 2;

    void corner(double x, double y, double dx, double dy) {
      final path = Path()
        ..moveTo(x, y + dy * arm)
        ..lineTo(x, y + dy * r)
        ..quadraticBezierTo(x, y, x + dx * r, y)
        ..lineTo(x + dx * arm, y);
      canvas.drawPath(path, corners);
    }

    corner(h, h, 1, 1);
    corner(s - h, h, -1, 1);
    corner(h, s - h, 1, -1);
    corner(s - h, s - h, -1, -1);

    // Red line: the camera is waiting for a code.
    final y = s * 0.12 + (s * 0.76) * progress;
    final line = Rect.fromLTWH(s * 0.1, y - 1.5, s * 0.8, 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(line, const Radius.circular(2)),
      Paint()
        ..color = AppColors.red
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 6),
    );
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.progress != progress;
}
