// lib/core/theme/theme/dynamic_app_theme.dart
import 'package:flutter/material.dart';
import '../models/theme_state.dart';

class DynamicAppTheme {
  static ThemeData getLightTheme(ColorPalette palette) {
    final colorScheme = _getColorScheme(palette, Brightness.light);
    return _buildTheme(colorScheme);
  }

  static ThemeData getDarkTheme(ColorPalette palette) {
    final colorScheme = _getColorScheme(palette, Brightness.dark);
    return _buildTheme(colorScheme);
  }

  static ColorScheme _getColorScheme(
    ColorPalette palette,
    Brightness brightness,
  ) {
    final seedColor = _getSeedColor(palette);
    return ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
  }

  static Color _getSeedColor(ColorPalette palette) {
    switch (palette) {
      case ColorPalette.arcticBlue:
        return const Color(0xFF2196F3);
      case ColorPalette.emeraldGreen:
        return const Color(0xFF4CAF50);
      case ColorPalette.sunsetOrange:
        return const Color(0xFFFF9800);
      case ColorPalette.royalPurple:
        return const Color(0xFF9C27B0);
      case ColorPalette.crimsonRed:
        return const Color(0xFFF44336);
    }
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
    );
  }
}
