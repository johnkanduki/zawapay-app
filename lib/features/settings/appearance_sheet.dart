import 'package:flutter/material.dart';

import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// "Appearance": Automatic (follows the phone, the default for every new
/// account), Light or Dark. The choice applies to the whole app at once.
Future<void> showAppearanceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: AppColors.scrim,
    backgroundColor: Colors.transparent,
    builder: (_) => const AppearanceSheet(),
  );
}

/// Name of a mode, as shown in Settings ("Automatique", "Clair", "Sombre").
String themeModeName(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
  ThemeMode.light => l10n.appearanceLight,
  ThemeMode.dark => l10n.appearanceDark,
  ThemeMode.system => l10n.settingsAppearanceAuto,
};

class AppearanceSheet extends StatelessWidget {
  const AppearanceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = AppSettingsScope.maybeOf(context);
    final current = settings?.themeMode ?? ThemeMode.system;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = _SheetColors(dark);

    return FractionallySizedBox(
      heightFactor: 0.94,
      child: Container(
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.field,
                  ),
                  child: Icon(Icons.close_rounded, color: c.text),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: c.frame),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 16),
                      child: Text(
                        l10n.appearanceIntro,
                        style: TextStyle(fontSize: 16, color: c.soft),
                      ),
                    ),
                    for (final (mode, title, subtitle) in [
                      (
                        ThemeMode.system,
                        l10n.settingsAppearanceAuto,
                        l10n.appearanceAutoText,
                      ),
                      (ThemeMode.light, l10n.appearanceLight, null),
                      (ThemeMode.dark, l10n.appearanceDark, null),
                    ]) ...[
                      _Option(
                        mode: mode,
                        title: title,
                        subtitle: subtitle,
                        selected: current == mode,
                        colors: c,
                        onTap: () => settings?.setThemeMode(mode),
                      ),
                      if (mode != ThemeMode.dark) const SizedBox(height: 10),
                    ],
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

/// The sheet's own colours, for the light and the dark mode.
class _SheetColors {
  _SheetColors(bool dark)
    : background = dark ? AppColors.black : AppColors.surface,
      card = dark ? const Color(0x14FFFFFF) : AppColors.white,
      field = dark ? const Color(0x1FFFFFFF) : AppColors.surface,
      frame = dark ? const Color(0x0FFFFFFF) : const Color(0x0F000000),
      text = dark ? AppColors.white : AppColors.black,
      soft = dark ? const Color(0x99FFFFFF) : AppColors.grey;

  final Color background;
  final Color card;
  final Color field;
  final Color frame;
  final Color text;
  final Color soft;
}

class _Option extends StatelessWidget {
  const _Option({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final ThemeMode mode;
  final String title;
  final String? subtitle;
  final bool selected;
  final _SheetColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: ShapeDecoration(
            color: colors.field,
            shape: StadiumBorder(
              side: BorderSide(
                color: selected ? AppColors.red : Colors.transparent,
                width: 1.5,
              ),
            ),
          ),
          child: Row(
            children: [
              _Swatch(mode: mode),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colors.text,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(fontSize: 14, color: colors.soft),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Round choice: red ring and dot when selected.
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.red : colors.soft,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.red,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small rounded square: white (light), black (dark), or both cut on the
/// diagonal (automatic).
class _Swatch extends StatelessWidget {
  const _Swatch({required this.mode});

  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.5)),
          color: mode == ThemeMode.dark ? AppColors.black : AppColors.white,
        ),
        child: mode == ThemeMode.system
            ? const CustomPaint(painter: _DiagonalPainter())
            : null,
      ),
    );
  }
}

class _DiagonalPainter extends CustomPainter {
  const _DiagonalPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.black);
  }

  @override
  bool shouldRepaint(_DiagonalPainter oldDelegate) => false;
}
