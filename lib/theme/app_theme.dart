import 'package:flutter/material.dart';

/// APS Pro / pos_test PWA dark theme (from src/styles/theme.css).
class AppTheme {
  static const accent = Color(0xFFF97316);
  static const accentHover = Color(0xFFEA580C);
  static const bgPrimary = Color(0xFF121212);
  static const bgSecondary = Color(0xFF1A1A1A);
  static const bgCard = Color(0xFF1E1E1E);
  static const bgHover = Color(0xFF2A2A2A);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF999999);
  static const border = Color(0x66F97316);
  static const success = Color(0xFF10B981);
  static const danger = Color(0xFFEF4444);

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentHover,
        surface: bgCard,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: bgPrimary,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: bgSecondary,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgHover,
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgSecondary,
        indicatorColor: accent.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, color: textSecondary),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: bgHover,
        selectedColor: accent.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: textPrimary),
        side: const BorderSide(color: border),
      ),
    );
  }
}
