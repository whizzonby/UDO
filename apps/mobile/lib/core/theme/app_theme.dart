import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color udoGreen = Color(0xFF2E4A42);
  static const Color udoCrimson = Color(0xFFC9867A);
  static const Color udoPastelCrimson = Color(0xFFD9A59D);
  static const Color udoLightBlush = Color(0xFFF3E9E3);
  static const Color udoGold = Color(0xFFC9A46A);
  static const Color udoTeal = Color(0xFF295E61);
  static const Color udoBackground = Color(0xFFF8F8F5);
  static const Color udoSurface = Color(0xFFFFFFFF);
  static const Color udoCardFill = Color(0xFFFFFFFF);
  static const Color udoTextPrimary = Color(0xFF1C1917);
  static const Color udoTextSecondary = Color(0xFF6B6159);
  static const Color udoMuted = Color(0xFF9A9088);
  static const Color udoStone = Color(0xFFEAE4DB);
  static const Color udoBorder = udoStone;

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: udoGreen,
        primary: udoGreen,
        secondary: udoCrimson,
        tertiary: udoPastelCrimson,
        surface: udoSurface,
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 38,
          fontWeight: FontWeight.w400,
          color: udoTextPrimary,
          height: 1.08,
        ),
        displayMedium: GoogleFonts.dmSerifDisplay(
          fontSize: 30,
          fontWeight: FontWeight.w400,
          color: udoTextPrimary,
          height: 1.1,
        ),
        headlineMedium: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: udoTextPrimary,
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
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: udoTextPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: udoGreen,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(double.infinity, 52),
          textStyle:
              GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: udoGreen,
          side: const BorderSide(color: udoGreen),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: udoBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: udoBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: udoBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: udoGreen, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: udoBorder),
        ),
        color: udoCardFill,
      ),
      scaffoldBackgroundColor: udoBackground,
      dividerTheme: const DividerThemeData(color: udoBorder, space: 1),
    );
  }
}
