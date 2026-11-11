import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'zawapay_colors.dart';

/// Text styles shared by every screen. Their colours follow the mode
/// (light / dark), so they are read with the page's context.
abstract final class AppText {
  static TextStyle screenTitle(BuildContext context) => TextStyle(
    fontSize: 26,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: context.zc.text,
  );

  static TextStyle heroTitle(BuildContext context) => TextStyle(
    fontSize: 28,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: context.zc.text,
  );

  static TextStyle body(BuildContext context) =>
      TextStyle(fontSize: 15, height: 1.45, color: context.zc.soft);

  static TextStyle label(BuildContext context) =>
      TextStyle(fontSize: 14, color: context.zc.soft);

  // The family is set here too: a button's own style replaces the theme's,
  // so without it buttons would use the phone's font instead of Inter.
  static const TextStyle button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
}

abstract final class AppTheme {
  static ThemeData light() {
    const pageTransitions = PageTransitionsTheme(
      // Swipe from the left edge to go back, on iOS and Android.
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    );

    return ThemeData(
      useMaterial3: true,
      // One professional font everywhere, on iPhone and Android alike.
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.white,
      extensions: const [ZawapayColors.light],
      colorScheme: const ColorScheme.light(
        primary: AppColors.red,
        onPrimary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.black,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.red,
        selectionHandleColor: AppColors.red,
      ),
      pageTransitionsTheme: pageTransitions,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }

  /// Dark version, used when the user (or the phone, in Automatic) is in
  /// dark mode.
  static ThemeData dark() {
    final light = AppTheme.light();
    return light.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.black,
      extensions: const [ZawapayColors.dark],
      textTheme: light.textTheme.apply(
        bodyColor: AppColors.white,
        displayColor: AppColors.white,
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.red,
        onPrimary: AppColors.white,
        surface: AppColors.black,
        onSurface: AppColors.white,
      ),
    );
  }
}
