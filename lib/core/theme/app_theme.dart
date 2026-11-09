import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Text styles shared by every screen.
abstract final class AppText {
  static const TextStyle screenTitle = TextStyle(
    fontSize: 31,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
    color: AppColors.black,
  );

  static const TextStyle heroTitle = TextStyle(
    fontSize: 34,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColors.black,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.45,
    color: AppColors.grey,
  );

  static const TextStyle label = TextStyle(fontSize: 14, color: AppColors.grey);

  static const TextStyle button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
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
}
