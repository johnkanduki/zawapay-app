import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/auth_card_scaffold.dart';
import '../../../core/widgets/underlined_link.dart';
import '../../../l10n/app_localizations.dart';
import 'face_capture_screen.dart';

/// Last sign-up step, right after the e-mail code: the profile photo.
///
/// Tapping the circle opens the front camera straight away (never the
/// gallery). "Finish" stays grey until a photo with a face has been taken.
class ProfilePhotoScreen extends StatefulWidget {
  const ProfilePhotoScreen({super.key, required this.onFinished});

  /// Where "Finish" leads (the home page), with the photo taken.
  final void Function(BuildContext context, String photoPath) onFinished;

  @override
  State<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  String? _photoPath;

  Future<void> _openCamera() async {
    final path = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const FaceCaptureScreen(),
      ),
    );
    if (path == null || !mounted) return;
    final previous = _photoPath;
    setState(() => _photoPath = path);
    // The old photo is not kept anywhere.
    if (previous != null) File(previous).delete().ignore();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final photo = _photoPath;

    return AuthCardScaffold(
      title: l10n.profilePhotoTitle,
      subtitle: l10n.profilePhotoSubtitle,
      children: [
        const SizedBox(height: 6),
        Center(
          child: _PhotoCircle(photoPath: photo, onTap: _openCamera),
        ),
        const SizedBox(height: 18),
        Center(
          child: photo == null
              ? Text(
                  l10n.profilePhotoTapHint,
                  textAlign: TextAlign.center,
                  style: AppText.label.copyWith(fontSize: 15),
                )
              : UnderlinedLink(
                  text: l10n.profilePhotoRetake,
                  onTap: _openCamera,
                ),
        ),
        const SizedBox(height: 30),
        PrimaryButton(
          label: l10n.finish,
          onPressed: photo == null
              ? null
              : () => widget.onFinished(context, photo),
        ),
      ],
    );
  }
}

/// Big round button: camera icon before the photo, the photo afterwards.
class _PhotoCircle extends StatelessWidget {
  const _PhotoCircle({required this.photoPath, required this.onTap});

  final String? photoPath;
  final VoidCallback onTap;

  static const double _size = 190;

  @override
  Widget build(BuildContext context) {
    final photo = photoPath;
    const badgeSize = 52.0;

    return Semantics(
      button: true,
      label: AppLocalizations.of(context).profilePhotoTapHint,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox.square(
          dimension: _size,
          child: Stack(
            children: [
              Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(
                    color: photo == null ? AppColors.surface : AppColors.red,
                    width: 4,
                  ),
                ),
                child: ClipOval(
                  child: photo == null
                      ? const Icon(
                          Icons.person_rounded,
                          size: 110,
                          color: AppColors.white,
                        )
                      : Image.file(
                          File(photo),
                          fit: BoxFit.cover,
                          width: _size,
                          height: _size,
                        ),
                ),
              ),
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.red,
                    border: Border.all(color: AppColors.white, width: 4),
                  ),
                  child: Icon(
                    photo == null
                        ? Icons.photo_camera_rounded
                        : Icons.refresh_rounded,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
