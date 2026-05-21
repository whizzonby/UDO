import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.hotPink,
          secondary: AppColors.teal,
          surface: AppColors.white,
          error: AppColors.error,
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          onSurface: AppColors.black,
        ),
        scaffoldBackgroundColor: AppColors.white,
        textTheme: GoogleFonts.dmSansTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.forestGreen,
            foregroundColor: AppColors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.borderLg,
            ),
            elevation: 0,
            textStyle: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.forestGreen,
            minimumSize: const Size(double.infinity, 54),
            side: const BorderSide(color: AppColors.forestGreen, width: 1.5),
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.borderLg,
            ),
            textStyle: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.dustyRose,
            textStyle: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.grey100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: AppSpacing.borderMd,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderMd,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderMd,
            borderSide: const BorderSide(color: AppColors.forestGreen, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderMd,
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          hintStyle: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppColors.grey400,
          ),
          labelStyle: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppColors.grey600,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.grey200,
          thickness: 1,
          space: 0,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.dustyRose;
            return AppColors.grey300;
          }),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      );
}
