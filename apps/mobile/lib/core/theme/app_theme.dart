import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color udoGreen = Color(0xFF285301);
  static const Color udoCrimson = Color(0xFFD45D78);
  static const Color udoPastelCrimson = Color(0xFFF194B2);
  static const Color udoLightBlush = Color(0xFFF8EDEB);
  static const Color udoBackground = Color(0xFFFAFAFA);
  static const Color udoSurface = Color(0xFFFFFFFF);
  static const Color udoTextPrimary = Color(0xFF1A1A1A);
  static const Color udoTextSecondary = Color(0xFF6B7280);
  static const Color udoBorder = Color(0xFFE5E7EB);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: udoGreen,
        primary: udoGreen,
        secondary: udoCrimson,
        tertiary: udoPastelCrimson,
        surface: udoSurface,
        background: udoBackground,
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32, fontWeight: FontWeight.w600, color: udoGreen,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 26, fontWeight: FontWeight.w500, color: udoTextPrimary,
        ),
        headlineMedium: GoogleFonts.dmSans(
          fontSize: 20, fontWeight: FontWeight.w600, color: udoTextPrimary,
        ),
        bodyLarge: GoogleFonts.dmSans(fontSize: 16, color: udoTextPrimary),
        bodyMedium: GoogleFonts.dmSans(fontSize: 14, color: udoTextPrimary),
        labelSmall: GoogleFonts.dmSans(fontSize: 10, color: udoTextSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: udoSurface,
        foregroundColor: udoTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 18, fontWeight: FontWeight.w600, color: udoTextPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: udoGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(double.infinity, 52),
          textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: udoGreen,
          side: const BorderSide(color: udoGreen),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: udoLightBlush.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: udoBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: udoBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: udoGreen, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: udoBorder),
        ),
        color: udoSurface,
      ),
      scaffoldBackgroundColor: udoBackground,
      dividerTheme: const DividerThemeData(color: udoBorder, space: 1),
    );
  }
}
