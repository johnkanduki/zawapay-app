import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/account/account_error.dart';
import '../../core/account/zawapay_account.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zawapay_colors.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/top_notice.dart';
import '../../l10n/app_localizations.dart';
import '../auth/screens/face_capture_screen.dart';
import '../auth/screens/verify_code_screen.dart';
import 'settings_sheet.dart';

/// Settings → personal information: the photo (front camera only), first
/// name, last name and e-mail can change; the @ (at the end) never does.
/// A new e-mail needs two codes: one sent to the current address, then one
/// sent to the new address.
Future<void> showPersonalInfoSheet(BuildContext context) =>
    showSettingsSheet(context, card: (context) => const _PersonalInfoForm());

class _PersonalInfoForm extends StatefulWidget {
  const _PersonalInfoForm();

  @override
  State<_PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<_PersonalInfoForm> {
  final SignedIn? _me = zawapayAccount.current.value;
  late final _first = TextEditingController(text: _me?.firstName ?? '');
  late final _last = TextEditingController(text: _me?.lastName ?? '');
  late final _email = TextEditingController(text: _me?.email ?? '');
  bool _busy = false;
  bool _photoBusy = false;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

  @override
  void initState() {
    super.initState();
    for (final c in [_first, _last, _email]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    super.dispose();
  }

  bool get _nameChanged =>
      _first.text.trim() != (_me?.firstName ?? '') ||
      _last.text.trim() != (_me?.lastName ?? '');
  bool get _emailChanged =>
      _email.text.trim().toLowerCase() != (_me?.email ?? '').toLowerCase();
  bool get _canSave =>
      !_busy &&
      _first.text.trim().isNotEmpty &&
      _last.text.trim().isNotEmpty &&
      _emailPattern.hasMatch(_email.text.trim()) &&
      (_nameChanged || _emailChanged);

  /// Front camera only (never the gallery), then sent at once.
  Future<void> _changePhoto() async {
    final path = await Navigator.of(context, rootNavigator: true).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const FaceCaptureScreen(),
      ),
    );
    if (path == null || !mounted) return;
    setState(() => _photoBusy = true);
    try {
      await zawapayAccount.changePhoto(path);
    } catch (error) {
      if (mounted) showAccountError(context, error);
    } finally {
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      if (_nameChanged) {
        await zawapayAccount.saveName(_first.text.trim(), _last.text.trim());
      }
      if (_emailChanged) {
        if (!mounted) return;
        final changed = await _changeEmail(_email.text.trim().toLowerCase());
        if (!changed) return;
      }
      if (!mounted) return;
      showTopNotice(
        context,
        _emailChanged ? l10n.emailChanged : l10n.profileSaved,
      );
      navigator.pop();
    } catch (error) {
      if (mounted) showAccountError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Code on the current address, then code on the new one. True once the
  /// e-mail has changed.
  Future<bool> _changeEmail(String newEmail) async {
    zawapayAccount.lang = Localizations.localeOf(context).languageCode;
    final current = await zawapayAccount.startEmailChange(newEmail);
    if (!mounted) return false;
    var done = false;
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => VerifyCodeScreen(
          email: current,
          onResend: () => zawapayAccount.startEmailChange(newEmail),
          onVerified: (codeContext, code) async {
            final sentTo = await zawapayAccount.confirmCurrentEmail(code);
            if (!codeContext.mounted) return;
            await Navigator.of(codeContext).pushReplacement(
              MaterialPageRoute(
                builder: (_) => VerifyCodeScreen(
                  email: sentTo,
                  onVerified: (newContext, newCode) async {
                    await zawapayAccount.confirmNewEmail(newEmail, newCode);
                    done = true;
                    if (newContext.mounted) Navigator.of(newContext).pop();
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
    return done;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final zc = context.zc;
    final me = _me;
    final name = [
      _first.text.trim(),
      _last.text.trim(),
    ].where((p) => p.isNotEmpty).join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Photo, with a pencil: front camera only.
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: _photoBusy ? null : _changePhoto,
            child: SizedBox(
              width: 104,
              height: 104,
              child: Stack(
                children: [
                  ValueListenableBuilder<String?>(
                    valueListenable: zawapayAccount.photo,
                    builder: (context, photo, _) {
                      final path = photo ?? me?.photoPath;
                      return Container(
                        width: 94,
                        height: 94,
                        margin: const EdgeInsets.only(top: 10),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: zc.field,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        alignment: Alignment.center,
                        child: _photoBusy
                            ? const CircularProgressIndicator(
                                color: AppColors.red,
                              )
                            : path != null && File(path).existsSync()
                            ? Image.file(
                                File(path),
                                key: ValueKey(path),
                                cacheWidth: 300,
                                width: 94,
                                height: 94,
                                fit: BoxFit.cover,
                              )
                            : Text(
                                name.isEmpty ? '?' : name[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: zc.text,
                                ),
                              ),
                      );
                    },
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.red,
                        border: Border.all(color: zc.raised, width: 3),
                      ),
                      child: const Icon(
                        Icons.photo_camera_rounded,
                        size: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: zc.text,
            ),
          ),
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: l10n.firstNameLabel,
          hint: l10n.firstNameHint,
          controller: _first,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: l10n.lastNameLabel,
          hint: l10n.lastNameHint,
          controller: _last,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: l10n.emailLabel,
          hint: l10n.emailHint,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        // The @ is shown, never editable.
        FieldLabel(l10n.handleLabel),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: ShapeDecoration(
            color: zc.field,
            shape: const StadiumBorder(),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '@${me?.member.handle ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, color: zc.soft),
                ),
              ),
              Icon(Icons.lock_rounded, size: 18, color: zc.soft),
              const SizedBox(width: 6),
              Text(
                l10n.handleNeverChanges,
                style: TextStyle(fontSize: 13, color: zc.soft),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: l10n.save,
          busy: _busy,
          onPressed: _canSave ? _save : null,
        ),
      ],
    );
  }
}
