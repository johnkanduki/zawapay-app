import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The app's colours by ROLE, in a light and a dark version. Pages use
/// `context.zc.page`, `context.zc.text`… instead of a fixed black or white,
/// so every page follows Appearance (Automatic / Light / Dark).
///
/// The Zawapay red never changes. Fixed on purpose (not here): the QR code
/// (always black on white, for scanners), the shared QR image, photos, flags
/// and the blue badge.
@immutable
class ZawapayColors extends ThemeExtension<ZawapayColors> {
  const ZawapayColors({
    required this.page,
    required this.card,
    required this.cardStrong,
    required this.frame,
    required this.field,
    required this.text,
    required this.soft,
    required this.faint,
    required this.line,
    required this.inverse,
    required this.onInverse,
    required this.isDark,
    required this.backdrop,
    required this.raised,
  });

  /// Light: light grey page, white rounded cards, grey fields inside them,
  /// black text (the user's choice, 2026-11-11).
  static const light = ZawapayColors(
    page: AppColors.surface,
    card: AppColors.white,
    cardStrong: AppColors.white,
    frame: Color(0x0F000000),
    field: AppColors.surface,
    text: AppColors.black,
    soft: AppColors.grey,
    faint: Color(0x66000000),
    line: Color(0x14000000),
    inverse: AppColors.black,
    onInverse: AppColors.white,
    isDark: false,
    backdrop: AppColors.surface,
    raised: AppColors.white,
  );

  /// Dark: near-black page, see-through white cards, white text.
  static const dark = ZawapayColors(
    page: AppColors.black,
    card: Color(0x14FFFFFF),
    cardStrong: Color(0x1FFFFFFF),
    frame: Color(0x0FFFFFFF),
    field: Color(0x1FFFFFFF),
    text: AppColors.white,
    soft: Color(0x99FFFFFF),
    faint: Color(0x66FFFFFF),
    line: Color(0x14FFFFFF),
    inverse: AppColors.white,
    onInverse: AppColors.black,
    isDark: true,
    backdrop: AppColors.black,
    raised: Color(0xFF1C1C1E),
  );

  /// Behind the whole page.
  final Color page;

  /// Cards and pills on the page; [cardStrong] a bit more marked.
  final Color card;
  final Color cardStrong;

  /// Thin outer frame around cards.
  final Color frame;

  /// Inside of text fields and small boxes.
  final Color field;

  /// Main text, secondary text, hints.
  final Color text;
  final Color soft;
  final Color faint;

  /// Separators.
  final Color line;

  /// A card that stands out: white on dark, black on light (balance card).
  final Color inverse;
  final Color onInverse;

  final bool isDark;

  /// Behind a big rounded card (sign-in, sign-up pages): light grey / black.
  final Color backdrop;

  /// That big card, and bottom sheets: white / dark grey.
  final Color raised;

  @override
  ZawapayColors copyWith({
    Color? page,
    Color? card,
    Color? cardStrong,
    Color? frame,
    Color? field,
    Color? text,
    Color? soft,
    Color? faint,
    Color? line,
    Color? inverse,
    Color? onInverse,
    bool? isDark,
    Color? backdrop,
    Color? raised,
  }) => ZawapayColors(
    page: page ?? this.page,
    card: card ?? this.card,
    cardStrong: cardStrong ?? this.cardStrong,
    frame: frame ?? this.frame,
    field: field ?? this.field,
    text: text ?? this.text,
    soft: soft ?? this.soft,
    faint: faint ?? this.faint,
    line: line ?? this.line,
    inverse: inverse ?? this.inverse,
    onInverse: onInverse ?? this.onInverse,
    isDark: isDark ?? this.isDark,
    backdrop: backdrop ?? this.backdrop,
    raised: raised ?? this.raised,
  );

  @override
  ZawapayColors lerp(ZawapayColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return ZawapayColors(
      page: mix(page, other.page),
      card: mix(card, other.card),
      cardStrong: mix(cardStrong, other.cardStrong),
      frame: mix(frame, other.frame),
      field: mix(field, other.field),
      text: mix(text, other.text),
      soft: mix(soft, other.soft),
      faint: mix(faint, other.faint),
      line: mix(line, other.line),
      inverse: mix(inverse, other.inverse),
      onInverse: mix(onInverse, other.onInverse),
      isDark: t < 0.5 ? isDark : other.isDark,
      backdrop: mix(backdrop, other.backdrop),
      raised: mix(raised, other.raised),
    );
  }
}

extension ZawapayColorsOf on BuildContext {
  /// The colours of the current mode (light when no theme, e.g. in tests).
  ZawapayColors get zc =>
      Theme.of(this).extension<ZawapayColors>() ?? ZawapayColors.light;
}
