import 'package:flutter/material.dart';

abstract final class AppColors {
  // Onboarding / Auth palette
  static const Color cream = Color(0xFFFAF0EC);
  static const Color forestGreen = Color(0xFF2D5016);
  static const Color forestGreenLight = Color(0xFF3A5F0B);
  static const Color dustyRose = Color(0xFFBE5B73);
  static const Color dustyRoseLight = Color(0xFFC1637A);

  // Dashboard palette
  static const Color hotPink = Color(0xFFFF4D8C);
  static const Color hotPinkLight = Color(0xFFFF79A8);
  static const Color magenta = Color(0xFFE91E8C);
  static const Color pinkGradientStart = Color(0xFFFF4D8C);
  static const Color pinkGradientEnd = Color(0xFFD4006A);
  static const Color blushLight = Color(0xFFFFF0F5);
  static const Color teal = Color(0xFF2A9D8F);
  static const Color tealLight = Color(0xFFE8F7F5);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0D0D0D);
  static const Color grey100 = Color(0xFFF8F8F8);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFDDDDDD);
  static const Color grey400 = Color(0xFFBBBBBB);
  static const Color grey500 = Color(0xFF888888);
  static const Color grey600 = Color(0xFF555555);
  static const Color grey700 = Color(0xFF333333);

  // Semantic
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFD69E2E);
  static const Color info = Color(0xFF3182CE);

  // Card backgrounds
  static const Color cardBg = white;
  static const Color cardBgAlt = Color(0xFFFFF5F8);

  // Onboarding selection state
  static const Color selectionBorder = dustyRose;
  static const Color selectionFill = Color(0xFFFFF0F3);
}
