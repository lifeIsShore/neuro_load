import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Theme Variant Enum ────────────────────────────────────────────────────────

/// Feature 02: The five named themes available in Settings → Appearance.
enum AppThemeVariant {
  obsidianNoir,
  ashLight,
  paper,
  dusk,
  forest;

  String get label => switch (this) {
        obsidianNoir => 'Obsidian Noir',
        ashLight     => 'Ash Light',
        paper        => 'Paper',
        dusk         => 'Dusk',
        forest       => 'Forest',
      };

  bool get isDark => switch (this) {
        obsidianNoir => true,
        ashLight     => false,
        paper        => false,
        dusk         => true,
        forest       => true,
      };
}

// ── Per-theme colour palette ──────────────────────────────────────────────────

/// A resolved colour set for a single theme variant.
/// Used by [AppTheme._buildFromPalette] to construct [ThemeData].
class ThemePalette {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color accentDim;
  final Color border;
  final Color danger;
  final Color dangerDim;
  final bool isDark;

  const ThemePalette({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentDim,
    required this.border,
    required this.danger,
    required this.dangerDim,
    required this.isDark,
  });

  // ── Obsidian Noir (original default) ─────────────────────────────────────
  static const obsidianNoir = ThemePalette(
    background:     Color(0xFF0A0A0A),
    surface:        Color(0xFF141414),
    surfaceElevated:Color(0xFF1E1E1E),
    textPrimary:    Color(0xFFE8E8E8),
    textSecondary:  Color(0xFF888888),
    textTertiary:   Color(0xFF555555),
    accent:         Color(0xFF00B5A5),
    accentDim:      Color(0xFF007A6E),
    border:         Color(0xFF505050),
    danger:         Color(0xFFE53E3E),
    dangerDim:      Color(0xFF742A2A),
    isDark: true,
  );

  // ── Ash Light ─────────────────────────────────────────────────────────────
  static const ashLight = ThemePalette(
    background:     Color(0xFFF5F5F3),
    surface:        Color(0xFFEEEEEC),
    surfaceElevated:Color(0xFFE4E4E2),
    textPrimary:    Color(0xFF1A1A1A),
    textSecondary:  Color(0xFF5C5C5C),
    textTertiary:   Color(0xFF9A9A9A),
    accent:         Color(0xFF009688),
    accentDim:      Color(0xFF00695C),
    border:         Color(0xFFD0D0CE),
    danger:         Color(0xFFD32F2F),
    dangerDim:      Color(0xFFFFCDD2),
    isDark: false,
  );

  // ── Paper ─────────────────────────────────────────────────────────────────
  static const paper = ThemePalette(
    background:     Color(0xFFF8F4EE),
    surface:        Color(0xFFF0EBE3),
    surfaceElevated:Color(0xFFE8E2D9),
    textPrimary:    Color(0xFF2C2416),
    textSecondary:  Color(0xFF6B5E4E),
    textTertiary:   Color(0xFFA8967E),
    accent:         Color(0xFF3D7A6E),
    accentDim:      Color(0xFF2A5449),
    border:         Color(0xFFD8CFC4),
    danger:         Color(0xFFBF360C),
    dangerDim:      Color(0xFFFFCCBC),
    isDark: false,
  );

  // ── Dusk ─────────────────────────────────────────────────────────────────
  static const dusk = ThemePalette(
    background:     Color(0xFF1E1C2E),
    surface:        Color(0xFF262437),
    surfaceElevated:Color(0xFF2F2C42),
    textPrimary:    Color(0xFFE2DFFF),
    textSecondary:  Color(0xFF9B97B8),
    textTertiary:   Color(0xFF605C7A),
    accent:         Color(0xFFC9A84C),
    accentDim:      Color(0xFF8C7233),
    border:         Color(0xFF3D3A54),
    danger:         Color(0xFFE57373),
    dangerDim:      Color(0xFF4A1C1C),
    isDark: true,
  );

  // ── Forest ────────────────────────────────────────────────────────────────
  static const forest = ThemePalette(
    background:     Color(0xFF0F1A15),
    surface:        Color(0xFF162013),
    surfaceElevated:Color(0xFF1D2B1A),
    textPrimary:    Color(0xFFD8EDD6),
    textSecondary:  Color(0xFF8AAF85),
    textTertiary:   Color(0xFF4D6F49),
    accent:         Color(0xFF6FBA6A),
    accentDim:      Color(0xFF3D7838),
    border:         Color(0xFF2D4029),
    danger:         Color(0xFFEF9A9A),
    dangerDim:      Color(0xFF3B1212),
    isDark: true,
  );

  static ThemePalette forVariant(AppThemeVariant v) => switch (v) {
        AppThemeVariant.obsidianNoir => obsidianNoir,
        AppThemeVariant.ashLight     => ashLight,
        AppThemeVariant.paper        => paper,
        AppThemeVariant.dusk         => dusk,
        AppThemeVariant.forest       => forest,
      };
}

// ── AppColors (static, always Obsidian Noir) ──────────────────────────────────
//
// AppColors is kept for backward-compat with all the existing widget code
// that directly references `AppColors.teal`, `AppColors.background`, etc.
// It always reflects the Obsidian Noir palette.  Theme-aware colours are
// accessed via ThemePalette or Theme.of(context).colorScheme.

class AppColors {
  // Focus Mode (Dark - Obsidian Noir)
  static const Color background     = Color(0xFF0A0A0A);
  static const Color surface        = Color(0xFF141414);
  static const Color surfaceElevated= Color(0xFF1E1E1E);

  static const Color silverGray     = Color(0xFFA0A0A0);
  static const Color silverGrayLight= Color(0xFFD4D4D4);
  static const Color silverGrayDim  = Color(0xFF505050);

  static const Color teal           = Color(0xFF00B5A5);
  static const Color tealDim        = Color(0xFF007A6E);

  static const Color white          = Color(0xFFFFFFFF);
  static const Color offWhite       = Color(0xFFF5F5F0);
  static const Color textPrimary    = Color(0xFFE8E8E8);
  static const Color textSecondary  = Color(0xFF888888);
  static const Color textTertiary   = Color(0xFF555555);

  static const Color danger         = Color(0xFFE53E3E);
  static const Color dangerDim      = Color(0xFF742A2A);
  static const Color warning        = Color(0xFFD69E2E);
  static const Color success        = Color(0xFF38A169);

  // Rest Mode (Rest Palette - Mid-Century Teal/Sage)
  static const Color restBackground = Color(0xFF0D1F1E);
  static const Color restSurface    = Color(0xFF152928);
  static const Color restAccent     = Color(0xFF4DD9CC);
  static const Color restText       = Color(0xFFB2DFDB);

  // High-Contrast palette (Accessibility)
  static const Color highContrastAccent = Color(0xFFFFD700);
  static const Color highContrastBorder = Color(0xFFFFFFFF);

  // Category colors (shared across all themes)
  static const Color categoryStudy    = Color(0xFF6B9BD2);
  static const Color categoryWork     = Color(0xFF8B9E77);
  static const Color categoryCreative = Color(0xFFB07ABB);
  static const Color categoryAdmin    = Color(0xFFD4956A);
  static const Color categoryLifestyle= Color(0xFF6BBCB0);
}

// ── AppTheme ──────────────────────────────────────────────────────────────────

class AppTheme {
  // ── Feature 02: main entry point ─────────────────────────────────────────

  /// Builds the full [ThemeData] for the given [variant], font, and
  /// accessibility settings.  Called from [NeuroLoadApp] in main.dart.
  static ThemeData forVariant(
    AppThemeVariant variant, {
    bool highContrast = false,
    String fontFamily = 'Inter',
  }) {
    final palette = ThemePalette.forVariant(variant);
    return _buildFromPalette(
      palette,
      highContrast: highContrast,
      fontFamily: fontFamily,
    );
  }

  // ── Legacy entry points (kept for backward-compat) ────────────────────────

  /// Builds the default Obsidian Noir theme with optional accessibility
  /// overrides.  Existing call sites that use [buildTheme] continue to work.
  static ThemeData buildTheme({
    bool highContrast = false,
    String fontFamily = 'Inter',
  }) =>
      forVariant(AppThemeVariant.obsidianNoir,
          highContrast: highContrast, fontFamily: fontFamily);

  static ThemeData get darkTheme => forVariant(AppThemeVariant.obsidianNoir);

  static ThemeData get restTheme {
    return darkTheme.copyWith(
      scaffoldBackgroundColor: AppColors.restBackground,
      colorScheme: ThemeData.dark(useMaterial3: true).colorScheme.copyWith(
            primary: AppColors.restAccent,
            surface: AppColors.restSurface,
          ),
    );
  }

  // ── Core builder ─────────────────────────────────────────────────────────

  static ThemeData _buildFromPalette(
    ThemePalette p, {
    bool highContrast = false,
    String fontFamily = 'Inter',
  }) {
    final accent = highContrast ? AppColors.highContrastAccent : p.accent;
    final borderColor = highContrast ? AppColors.highContrastBorder : p.border;
    final base = p.isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    final textTheme = _buildTextTheme(
      base.textTheme,
      palette: p,
      fontFamily: fontFamily,
      highContrast: highContrast,
    );

    return base.copyWith(
      scaffoldBackgroundColor: p.background,
      colorScheme: (p.isDark ? const ColorScheme.dark() : const ColorScheme.light())
          .copyWith(
        primary:   accent,
        onPrimary: p.background,
        secondary: p.textSecondary,
        surface:   p.surface,
        onSurface: p.textPrimary,
        error:     p.danger,
        outline:   borderColor,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.getFont(
          fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: p.textSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.surface,
        selectedItemColor: accent,
        unselectedItemColor: p.border,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: p.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 0.5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceElevated,
        hintStyle: GoogleFonts.getFont(
          fontFamily,
          color: p.textTertiary,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.getFont(
          fontFamily,
          color: p.textSecondary,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: p.isDark ? p.background : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: GoogleFonts.getFont(
            fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textSecondary,
          side: BorderSide(color: borderColor, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: GoogleFonts.getFont(
            fontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.surfaceElevated,
        contentTextStyle: GoogleFonts.getFont(
          fontFamily,
          color: p.textPrimary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(p.background),
        side: BorderSide(color: borderColor),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return p.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accent.withOpacity(0.4);
          }
          return p.border.withOpacity(0.5);
        }),
      ),
    );
  }

  // ── Text theme ────────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme(
    TextTheme base, {
    required ThemePalette palette,
    String fontFamily = 'Inter',
    bool highContrast = false,
  }) {
    final p = palette;
    final bodyColor     = highContrast ? p.textPrimary : p.textSecondary;
    final tertiaryColor = highContrast ? p.textSecondary : p.textTertiary;

    // Resolves the UI font so any Google Font can be used as the body typeface.
    TextStyle f({
      required double size,
      required FontWeight weight,
      required Color color,
      double? ls,
      double? h,
    }) =>
        GoogleFonts.getFont(fontFamily,
            fontSize: size,
            fontWeight: weight,
            color: color,
            letterSpacing: ls,
            height: h);

    return base.copyWith(
      // Display styles keep PlayfairDisplay for the in-app timer numerals
      displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 72, fontWeight: FontWeight.w700,
          color: p.textPrimary, letterSpacing: -2),
      displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 48, fontWeight: FontWeight.w700,
          color: p.textPrimary, letterSpacing: -1),
      displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 36, fontWeight: FontWeight.w600,
          color: p.textPrimary),
      // UI styles use the selected font family
      headlineLarge:  f(size: 28, weight: FontWeight.w700, color: p.textPrimary, ls: -0.5),
      headlineMedium: f(size: 22, weight: FontWeight.w600, color: p.textPrimary),
      headlineSmall:  f(size: 18, weight: FontWeight.w600, color: p.textPrimary),
      titleLarge:     f(size: 16, weight: FontWeight.w600, color: p.textPrimary, ls: 0.2),
      titleMedium:    f(size: 14, weight: FontWeight.w500, color: p.textPrimary),
      titleSmall:     f(size: 12, weight: FontWeight.w500, color: p.textSecondary, ls: 0.5),
      bodyLarge:      f(size: 16, weight: FontWeight.w400, color: p.textPrimary, h: 1.6),
      bodyMedium:     f(size: 14, weight: FontWeight.w400, color: bodyColor, h: 1.5),
      bodySmall:      f(size: 12, weight: FontWeight.w400, color: tertiaryColor, h: 1.4),
      labelLarge:     f(size: 14, weight: FontWeight.w600, color: p.textPrimary, ls: 0.8),
      labelMedium:    f(size: 12, weight: FontWeight.w500, color: bodyColor, ls: 0.5),
      labelSmall:     f(size: 10, weight: FontWeight.w500, color: tertiaryColor, ls: 1),
    );
  }
}
