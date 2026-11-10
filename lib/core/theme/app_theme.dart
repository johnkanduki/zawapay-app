import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Text styles shared by every screen.
abstract final class AppText {
  static const TextStyle screenTitle = TextStyle(
    fontSize: 26,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: AppColors.black,
  );

  static const TextStyle heroTitle = TextStyle(
    fontSize: 28,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColors.black,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.45,
    color: AppColors.grey,
  );

  static const TextStyle label = TextStyle(fontSize: 14, color: AppColors.grey);

  static const TextStyle button = TextStyle(
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
      colorScheme: const ColorScheme.dark(
        primary: AppColors.red,
        onPrimary: AppColors.white,
        surface: AppColors.black,
        onSurface: AppColors.white,
      ),
    );
  }
}
