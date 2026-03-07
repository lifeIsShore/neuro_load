import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Focus Mode (Dark - Obsidian Noir)
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceElevated = Color(0xFF1E1E1E);

  static const Color silverGray = Color(0xFFA0A0A0);
  static const Color silverGrayLight = Color(0xFFD4D4D4);
  static const Color silverGrayDim = Color(0xFF505050);

  static const Color teal = Color(0xFF00B5A5);
  static const Color tealDim = Color(0xFF007A6E);

  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F5F0);
  static const Color textPrimary = Color(0xFFE8E8E8);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textTertiary = Color(0xFF555555);

  static const Color danger = Color(0xFFE53E3E);
  static const Color dangerDim = Color(0xFF742A2A);
  static const Color warning = Color(0xFFD69E2E);
  static const Color success = Color(0xFF38A169);

  // Rest Mode (Rest Palette - Mid-Century Teal/Sage)
  static const Color restBackground = Color(0xFF0D1F1E);
  static const Color restSurface = Color(0xFF152928);
  static const Color restAccent = Color(0xFF4DD9CC);
  static const Color restText = Color(0xFFB2DFDB);

  // High-Contrast palette (Accessibility)
  static const Color highContrastAccent = Color(0xFFFFD700);
  static const Color highContrastBorder = Color(0xFFFFFFFF);

  // Category colors
  static const Color categoryStudy = Color(0xFF6B9BD2);
  static const Color categoryWork = Color(0xFF8B9E77);
  static const Color categoryCreative = Color(0xFFB07ABB);
  static const Color categoryAdmin = Color(0xFFD4956A);
  static const Color categoryLifestyle = Color(0xFF6BBCB0);
}

class AppTheme {
  /// Bug 06 fix: build a theme that responds to accessibility settings.
  /// [highContrast] switches accent colours to WCAG 7:1 gold palette.
  /// [fontFamily] allows switching away from Inter (e.g. OpenDyslexic).
  static ThemeData buildTheme({
    bool highContrast = false,
    String fontFamily = 'Inter',
  }) {
    final base = darkTheme;
    if (!highContrast && fontFamily == 'Inter') return base;

    final accent = highContrast ? AppColors.highContrastAccent : AppColors.teal;
    final borderColor =
        highContrast ? AppColors.highContrastBorder : AppColors.silverGrayDim;

    // Bug 13a fix: use darkTheme's textTheme as the base (not a plain
    // ThemeData.dark()) so all the custom Inter styles are preserved when
    // only the fontFamily changes.  _buildTextTheme then overrides the
    // fontFamily on every style while keeping sizes, weights, and colors.
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: accent,
        outline: borderColor,
      ),
      textTheme: _buildTextTheme(
        base.textTheme,             // Bug 13a: was ThemeData.dark().textTheme
        fontFamily: fontFamily,
        highContrast: highContrast,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.teal,
        onPrimary: AppColors.background,
        secondary: AppColors.silverGray,
        onSecondary: AppColors.background,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
        onError: AppColors.white,
        outline: AppColors.silverGrayDim,
      ),
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.silverGray),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.teal,
        unselectedItemColor: AppColors.silverGrayDim,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.silverGrayDim, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.silverGrayDim,
        thickness: 0.5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        hintStyle: GoogleFonts.inter(
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.silverGrayDim,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.silverGrayDim,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: AppColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.silverGray,
          side: const BorderSide(color: AppColors.silverGrayDim, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: GoogleFonts.inter(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get restTheme {
    return darkTheme.copyWith(
      scaffoldBackgroundColor: AppColors.restBackground,
      colorScheme: ThemeData.dark(useMaterial3: true).colorScheme.copyWith(
            primary: AppColors.restAccent,
            surface: AppColors.restSurface,
          ),
    );
  }

  static TextTheme _buildTextTheme(
    TextTheme base, {
    String fontFamily = 'Inter',
    bool highContrast = false,
  }) {
    // High contrast: bump all non-primary text to textPrimary for readability.
    final bodyColor =
        highContrast ? AppColors.textPrimary : AppColors.textSecondary;
    final tertiaryColor =
        highContrast ? AppColors.silverGray : AppColors.textTertiary;

    // Bug 13a fix: resolve the UI font dynamically so selecting a non-Inter
    // font in Settings actually changes how text renders across the whole app.
    // GoogleFonts.getFont() returns the correct TextStyle for any Google Font.
    TextStyle uiFont({
      required double fontSize,
      required FontWeight fontWeight,
      required Color color,
      double? letterSpacing,
      double? height,
    }) {
      return GoogleFonts.getFont(
        fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }

    return base.copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 72,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -2,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -1,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineLarge: uiFont(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: uiFont(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineSmall: uiFont(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: uiFont(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
      ),
      titleMedium: uiFont(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleSmall: uiFont(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
      bodyLarge: uiFont(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.6,
      ),
      bodyMedium: uiFont(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: bodyColor,
        height: 1.5,
      ),
      bodySmall: uiFont(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: tertiaryColor,
        height: 1.4,
      ),
      labelLarge: uiFont(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.8,
      ),
      labelMedium: uiFont(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: bodyColor,
        letterSpacing: 0.5,
      ),
      labelSmall: uiFont(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: tertiaryColor,
        letterSpacing: 1,
      ),
    );
  }
}
