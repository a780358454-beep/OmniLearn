import 'package:flutter/material.dart';
import '../design/design_tokens.dart';

class AppTheme {
  // الوضع الداكن (Dark Mode)
  static ThemeData dark({
    Color primary = ColorTokens.primary,
    Color accent = ColorTokens.accent,
  }) {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primary.withOpacity(0.2),
      onPrimaryContainer: Colors.white,
      secondary: accent,
      onSecondary: Colors.white,
      surface: ColorTokens.darkSurface,
      onSurface: ColorTokens.textHigh,
      surfaceContainerLowest: const Color(0xFF020617),
      surfaceContainerLow: ColorTokens.darkBackground,
      surfaceContainer: ColorTokens.darkSurface,
      surfaceContainerHigh: ColorTokens.darkCard,
      surfaceContainerHighest: ColorTokens.darkBorder,
      onSurfaceVariant: ColorTokens.textMuted,
      outline: ColorTokens.darkBorder,
      outlineVariant: Color(0xFF475569),
      error: ColorTokens.error,
      onError: Colors.white,
    );

    return _buildTheme(colorScheme);
  }

  // الوضع الفاتح (Light Mode)
  static ThemeData light({
    Color primary = ColorTokens.primary,
    Color accent = ColorTokens.accent,
  }) {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primary.withOpacity(0.12),
      onPrimaryContainer: primary,
      secondary: accent,
      onSecondary: Colors.white,
      surface: ColorTokens.lightSurface,
      onSurface: const Color(0xFF0F172A),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: ColorTokens.lightBackground,
      surfaceContainer: ColorTokens.lightCard,
      surfaceContainerHigh: const Color(0xFFE2E8F0),
      surfaceContainerHighest: const Color(0xFFCBD5E1),
      onSurfaceVariant: const Color(0xFF64748B),
      outline: ColorTokens.lightBorder,
      outlineVariant: const Color(0xFFCBD5E1),
      error: ColorTokens.error,
      onError: Colors.white,
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surfaceContainerLow,
      fontFamily: 'Cairo', // Falls back gracefully to system sans-serif
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: AppTypography.title.copyWith(color: colorScheme.onSurface),
      ),
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.card),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(88, 48), // الهدف اللمسي 48dp
          padding: const EdgeInsets.symmetric(horizontal: Space.xl, vertical: Space.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.card),
          ),
          textStyle: AppTypography.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size(88, 48),
          side: BorderSide(color: colorScheme.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.sm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.card),
          ),
          textStyle: AppTypography.label,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.field),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.field),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.field),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        hintStyle: AppTypography.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
        labelStyle: AppTypography.bodySmall.copyWith(color: colorScheme.onSurface),
      ),
    );
  }
}
