import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  // Display — Playfair Display (serif, logo & onboarding headings)
  static TextStyle get displayLarge => GoogleFonts.playfairDisplay(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.forestGreen,
        height: 1.1,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.forestGreen,
        height: 1.2,
        letterSpacing: -0.3,
      );

  static TextStyle get displaySmall => GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.forestGreen,
        height: 1.2,
      );

  // Headings — DM Sans (sans-serif)
  static TextStyle get headingLarge => GoogleFonts.dmSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
        height: 1.3,
      );

  static TextStyle get headingMedium => GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
        height: 1.3,
      );

  static TextStyle get headingSmall => GoogleFonts.dmSans(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
        height: 1.4,
      );

  // Body — DM Sans
  static TextStyle get bodyLarge => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.grey700,
        height: 1.6,
      );

  static TextStyle get bodyMedium => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.grey700,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.grey500,
        height: 1.5,
      );

  // Labels / UI
  static TextStyle get labelLarge => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  static TextStyle get labelSmall => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      );

  // Button
  static TextStyle get button => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  // Caption / hint
  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.grey500,
        height: 1.4,
      );
}
