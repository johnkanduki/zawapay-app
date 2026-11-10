import 'package:flutter/material.dart';

/// Official Zawapay App palette. No other colour is used in the UI.
abstract final class AppColors {
  static const Color red = Color(0xFFE30613);
  static const Color black = Color(0xFF0D0D0D);
  static const Color grey = Color(0xFF5A5A5A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF2F2F2);

  /// Light blue of the certification badge. The only colour outside the
  /// palette, kept for the badge of a certified (KYC) account.
  static const Color verified = Color(0xFF1D9BF0);

  /// Dark veil behind bottom sheets.
  static const Color scrim = Color(0x73000000);
}
