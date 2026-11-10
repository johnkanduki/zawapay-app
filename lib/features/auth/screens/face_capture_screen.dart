import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../l10n/app_localizations.dart';

/// Full-screen front camera for the profile photo.
///
/// The photo can only be taken while exactly one face, close enough, is seen
/// in the circle. It is kept in the app's temporary folder: it never goes to
/// the phone's gallery, and the gallery is never offered.
///
/// Pops with the path of the photo, or null if the user closes the camera.
class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({super.key});

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

enum _FaceState { searching, noFace, tooFar, severalFaces, ready }

enum _CameraProblem { none, noCamera, denied, failed }

class _FaceCaptureScreenState extends State<FaceCaptureScreen>
    with WidgetsBindingObserver {
  /// A face must fill at least this share of the picture width.
  static const double _minFaceShare = 0.28;

  final _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.15,
    ),
  );

  CameraController? _controller;
  _CameraProblem _problem = _CameraProblem.none;
  _FaceState _face = _FaceState.searching;
  bool _busy = false;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _openCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _closeCamera();
    _detector.close();
    super.dispose();
  }

  // The camera is released when the app goes to the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _closeCamera();
    } else if (state == AppLifecycleState.resumed && _controller == null) {
      _openCamera();
    }
  }

  Future<void> _openCamera() async {
    setState(() {
      _problem = _CameraProblem.none;
      _face = _FaceState.searching;
    });

    try {
      final cameras = await availableCameras();
      final front = cameras
          .where((c) => c.lensDirection == CameraLensDirection.front)
          .firstOrNull;
      if (front == null) {
        if (mounted) setState(() => _problem = _CameraProblem.noCamera);
        return;
      }

      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      setState(() => _controller = controller);
      await controller.startImageStream(_onFrame);
    } on CameraException catch (error) {
      if (!mounted) return;
      final denied =
          error.code.contains('Denied') || error.code.contains('Restricted');
      setState(
        () => _problem = denied ? _CameraProblem.denied : _CameraProblem.failed,
      );
    }
  }

  Future<void> _closeCamera() async {
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    if (controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
    await controller.dispose();
  }

  /// Looks for a face in one camera frame (frames are skipped while busy).
  Future<void> _onFrame(CameraImage image) async {
    if (_busy || _capturing) return;
    final controller = _controller;
    if (controller == null) return;
    final input = _toInputImage(image, controller.description);
    if (input == null) return;

    _busy = true;
    try {
      final faces = await _detector.processImage(input);
      // The picture is in landscape: its height is the width once upright.
      final uprightWidth = image.width < image.height
          ? image.width
          : image.height;
      final next = switch (faces.length) {
        0 => _FaceState.noFace,
        > 1 => _FaceState.severalFaces,
        _ =>
          faces.first.boundingBox.width / uprightWidth < _minFaceShare
              ? _FaceState.tooFar
              : _FaceState.ready,
      };
      if (mounted && next != _face) setState(() => _face = next);
    } catch (_) {
      // A frame that cannot be read is simply ignored.
    } finally {
      _busy = false;
    }
  }

  InputImage? _toInputImage(CameraImage image, CameraDescription camera) {
    final InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    } else {
      // Phone held upright: the front camera picture is turned by its
      // sensor angle.
      rotation = InputImageRotationValue.fromRawValue(
        camera.sensorOrientation % 360,
      );
    }
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (rotation == null || format == null || image.planes.isEmpty) {
      return null;
    }
    final bytes = image.planes.length == 1
        ? image.planes.first.bytes
        : _join(image.planes);

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Uint8List _join(List<Plane> planes) {
    final all = WriteBuffer();
    for (final plane in planes) {
      all.putUint8List(plane.bytes);
    }
    return all.done().buffer.asUint8List();
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _face != _FaceState.ready || _capturing) return;
    setState(() => _capturing = true);
    try {
      await controller.stopImageStream();
      final photo = await controller.takePicture();
      if (mounted) Navigator.of(context).pop(photo.path);
    } on CameraException {
      if (!mounted) return;
      setState(() => _capturing = false);
      await controller.startImageStream(_onFrame);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ready = _face == _FaceState.ready;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _CloseButton(onTap: () => Navigator.of(context).pop()),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.faceCaptureTitle,
                  textAlign: TextAlign.center,
                  style: AppText.screenTitle.copyWith(color: AppColors.white),
                ),
                const Spacer(),
                if (_problem != _CameraProblem.none)
                  _ProblemMessage(problem: _problem, onRetry: _openCamera)
                else ...[
                  _FaceCircle(controller: _controller, ready: ready),
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _hint(l10n),
                      key: ValueKey(_face),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ready ? AppColors.white : AppColors.surface,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (_problem == _CameraProblem.none)
                  _ShutterButton(
                    enabled: ready && !_capturing,
                    onTap: _capture,
                  ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _hint(AppLocalizations l10n) => switch (_face) {
    _FaceState.searching || _FaceState.noFace => l10n.faceHintNoFace,
    _FaceState.tooFar => l10n.faceHintTooFar,
    _FaceState.severalFaces => l10n.faceHintSeveral,
    _FaceState.ready => l10n.faceHintReady,
  };
}

/// Round camera preview with a ring that turns red once the face is good.
class _FaceCircle extends StatelessWidget {
  const _FaceCircle({required this.controller, required this.ready});

  final CameraController? controller;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width * 0.78;
    final camera = controller;
    final previewSize = camera?.value.previewSize;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ready ? AppColors.red : AppColors.grey,
          width: 5,
        ),
      ),
      child: ClipOval(
        child: camera == null || previewSize == null
            ? const ColoredBox(
                color: Color(0x14FFFFFF),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.red),
                ),
              )
            : FittedBox(
                fit: BoxFit.cover,
                // The preview size is given in landscape.
                child: SizedBox(
                  width: previewSize.height,
                  height: previewSize.width,
                  child: CameraPreview(camera),
                ),
              ),
      ),
    );
  }
}

/// Big round shutter: white and red when a face is ready, grey otherwise.
class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: AppLocalizations.of(context).faceCaptureButton,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 84,
          height: 84,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: enabled ? AppColors.white : AppColors.grey,
              width: 4,
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: enabled ? AppColors.red : AppColors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0x1FFFFFFF),
        ),
        child: const Icon(Icons.close_rounded, color: AppColors.white),
      ),
    );
  }
}

/// Shown when the camera cannot be used (no camera, access refused…).
class _ProblemMessage extends StatelessWidget {
  const _ProblemMessage({required this.problem, required this.onRetry});

  final _CameraProblem problem;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = switch (problem) {
      _CameraProblem.noCamera => l10n.cameraNotAvailable,
      _CameraProblem.denied => l10n.cameraAccessDenied,
      _ => l10n.cameraFailed,
    };

    return Column(
      children: [
        const Icon(
          Icons.no_photography_outlined,
          size: 64,
          color: AppColors.surface,
        ),
        const SizedBox(height: 18),
        Text(
          text,
          textAlign: TextAlign.center,
          style: AppText.body.copyWith(color: AppColors.surface, fontSize: 17),
        ),
        const SizedBox(height: 26),
        PrimaryButton(label: l10n.retry, onPressed: onRetry),
      ],
    );
  }
}
