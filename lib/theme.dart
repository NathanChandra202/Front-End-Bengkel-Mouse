import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ============================================================
  // Brand Colors - Diambil langsung dari bengkelmouse.duaenam.id
  // Background: hsl(220, 20%, 6%) → ~#0C0F18
  // Card:       hsl(220, 20%, 9%) → ~#111520
  // Primary:    hsl(0, 80%, 55%)  → ~#E02222 (Crimson Red)
  // Foreground: hsl(0, 0%, 95%)   → ~#F2F2F2
  // Muted:      hsl(220, 10%, 55%)→ ~#7F8BA0
  // Border:     hsl(220, 15%, 18%)→ ~#232B3A
  // ============================================================

  static const Color backgroundColor  = Color(0xFF0C0F18); // true dark bg
  static const Color surfaceColor     = Color(0xFF111520); // card bg
  static const Color surfaceHighColor = Color(0xFF1A2031); // elevated surface

  static const Color primaryColor     = Color(0xFFE02222); // crimson red - brand
  static const Color primaryDark      = Color(0xFFB01A1A); // darker crimson
  static const Color primaryLight     = Color(0xFFE84444); // lighter for hover

  static const Color textColor        = Color(0xFFF2F2F2); // near-white
  static const Color textMuted        = Color(0xFF7F8BA0); // muted blue-grey
  static const Color borderColor      = Color(0xFF232B3A); // dark border

  // Status Colors (sama seperti sebelumnya tapi disesuaikan)
  static const Color statusWaiting    = Color(0xFF94A3B8);
  static const Color statusChecking   = Color(0xFFF59E0B);
  static const Color statusPayment    = Color(0xFFF97316);
  static const Color statusReview     = Color(0xFF818CF8);
  static const Color statusRepairing  = Color(0xFF38BDF8);
  static const Color statusQC         = Color(0xFFA78BFA);
  static const Color statusDone       = Color(0xFF22C55E);

  // Light Theme Colors
  static const Color backgroundColorLight = Color(0xFFF8F9FA); // Off-white background
  static const Color surfaceColorLight = Color(0xFFFFFFFF); // White cards
  static const Color surfaceHighColorLight = Color(0xFFF1F5F9); // Slightly gray surface
  
  static const Color textColorLight = Color(0xFF1E293B); // Dark slate
  static const Color textMutedLight = Color(0xFF64748B); // Slate gray
  static const Color borderColorLight = Color(0xFFE2E8F0); // Light gray border

  static ThemeData get darkTheme {
    final base = ThemeData.dark();

    return base.copyWith(
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryLight,
        surface: surfaceColor,
        error: Color(0xFFE02222),
        onPrimary: Colors.white,
        onSurface: textColor,
        onSecondary: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textColor, fontWeight: FontWeight.w700, letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.outfit(
          color: textColor, fontWeight: FontWeight.w700, letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.outfit(
          color: textColor, fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.outfit(
          color: textColor, fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: textColor, fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textColor, fontWeight: FontWeight.w600, fontSize: 20,
        ),
        titleMedium: GoogleFonts.outfit(
          color: textColor, fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.outfit(color: textColor, fontSize: 16),
        bodyMedium: GoogleFonts.outfit(color: textMuted, fontSize: 14),
        bodySmall: GoogleFonts.outfit(color: textMuted, fontSize: 12),
        labelLarge: GoogleFonts.outfit(
          color: textColor, fontWeight: FontWeight.w600, fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: textColor, fontSize: 18, fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textColor),
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 1),
        ),
        hintStyle: GoogleFonts.outfit(color: textMuted, fontSize: 14),
        labelStyle: GoogleFonts.outfit(color: textMuted, fontSize: 14),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor, thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceHighColor,
        contentTextStyle: GoogleFonts.outfit(color: textColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light();

    return base.copyWith(
      scaffoldBackgroundColor: backgroundColorLight,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryLight,
        surface: surfaceColorLight,
        error: Color(0xFFE02222),
        onPrimary: Colors.white,
        onSurface: textColorLight,
        onSecondary: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textColorLight, fontWeight: FontWeight.w700, letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.outfit(
          color: textColorLight, fontWeight: FontWeight.w700, letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.outfit(
          color: textColorLight, fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.outfit(
          color: textColorLight, fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: textColorLight, fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textColorLight, fontWeight: FontWeight.w600, fontSize: 20,
        ),
        titleMedium: GoogleFonts.outfit(
          color: textColorLight, fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.outfit(color: textColorLight, fontSize: 16),
        bodyMedium: GoogleFonts.outfit(color: textMutedLight, fontSize: 14),
        bodySmall: GoogleFonts.outfit(color: textMutedLight, fontSize: 12),
        labelLarge: GoogleFonts.outfit(
          color: textColorLight, fontWeight: FontWeight.w600, fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColorLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: textColorLight, fontSize: 18, fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textColorLight),
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColorLight,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderColorLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderColorLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 1),
        ),
        hintStyle: GoogleFonts.outfit(color: textMutedLight, fontSize: 14),
        labelStyle: GoogleFonts.outfit(color: textMutedLight, fontSize: 14),
        prefixIconColor: textMutedLight,
        suffixIconColor: textMutedLight,
      ),
      cardTheme: CardThemeData(
        color: surfaceColorLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderColorLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: borderColorLight, thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceHighColorLight,
        contentTextStyle: GoogleFonts.outfit(color: textColorLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColorLight,
        selectedItemColor: primaryColor,
        unselectedItemColor: textMutedLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
