import 'package:flutter/material.dart';

/// Enum for different color palette options
enum ColorPalette {
  seaBlue,
  forestGreen,
  sunsetOrange,
  midnightPurple,
  arcticBlue,
}

/// Base class for color palettes
abstract class AppColorPalette {
  Color get primary;
  Color get secondary;
  Color get background;
  Color get surface;
  Color get accent;
  Color get textPrimary;
  Color get textSecondary;
  Color get error;
  String get name;
}

/// Sea Blue palette (original)
class SeaBlueColorPalette extends AppColorPalette {
  @override
  Color get primary => const Color(0xFF1B263B);
  @override
  Color get secondary => const Color(0xFF468189);
  @override
  Color get background => const Color(0xFFA8DADC);
  @override
  Color get surface => const Color(0xFFF1FAEE);
  @override
  Color get accent => const Color(0xFFE63946);
  @override
  Color get textPrimary => const Color(0xFF0D1B2A);
  @override
  Color get textSecondary => const Color(0xFF468189);
  @override
  Color get error => const Color(0xFFE63946);
  @override
  String get name => 'Sea Blue';
}

/// Forest Green palette
class ForestGreenColorPalette extends AppColorPalette {
  @override
  Color get primary => const Color(0xFF2D5016);
  @override
  Color get secondary => const Color(0xFF52B788);
  @override
  Color get background => const Color(0xFFB7E4C7);
  @override
  Color get surface => const Color(0xFFF1F8E9);
  @override
  Color get accent => const Color(0xFFD4AF37);
  @override
  Color get textPrimary => const Color(0xFF1B4332);
  @override
  Color get textSecondary => const Color(0xFF52B788);
  @override
  Color get error => const Color(0xFFE63946);
  @override
  String get name => 'Forest Green';
}

/// Sunset Orange palette
class SunsetOrangeColorPalette extends AppColorPalette {
  @override
  Color get primary => const Color(0xFF8B4513);
  @override
  Color get secondary => const Color(0xFFFF7F50);
  @override
  Color get background => const Color(0xFFFFDAB9);
  @override
  Color get surface => const Color(0xFFFFF8DC);
  @override
  Color get accent => const Color(0xFFDC143C);
  @override
  Color get textPrimary => const Color(0xFF4A2C17);
  @override
  Color get textSecondary => const Color(0xFF8B4513);
  @override
  Color get error => const Color(0xFFE63946);
  @override
  String get name => 'Sunset Orange';
}

/// Midnight Purple palette
class MidnightPurpleColorPalette extends AppColorPalette {
  @override
  Color get primary => const Color(0xFF4A154B);
  @override
  Color get secondary => const Color(0xFF8E44AD);
  @override
  Color get background => const Color(0xFFE8D5E8);
  @override
  Color get surface => const Color(0xFFF8F5F8);
  @override
  Color get accent => const Color(0xFFE74C3C);
  @override
  Color get textPrimary => const Color(0xFF2C1A2C);
  @override
  Color get textSecondary => const Color(0xFF8E44AD);
  @override
  Color get error => const Color(0xFFE63946);
  @override
  String get name => 'Midnight Purple';
}

/// Arctic Blue palette
class ArcticBlueColorPalette extends AppColorPalette {
  @override
  Color get primary => const Color(0xFF1E3A8A);
  @override
  Color get secondary => const Color(0xFF3B82F6);
  @override
  Color get background => const Color(0xFFDBEAFE);
  @override
  Color get surface => const Color(0xFFF8FAFC);
  @override
  Color get accent => const Color(0xFF06B6D4);
  @override
  Color get textPrimary => const Color(0xFF0F172A);
  @override
  Color get textSecondary => const Color(0xFF3B82F6);
  @override
  Color get error => const Color(0xFFEF4444);
  @override
  String get name => 'Arctic Blue';
}

/// Factory class to create color palettes
class ColorPaletteFactory {
  static AppColorPalette getPalette(ColorPalette palette) {
    switch (palette) {
      case ColorPalette.seaBlue:
        return SeaBlueColorPalette();
      case ColorPalette.forestGreen:
        return ForestGreenColorPalette();
      case ColorPalette.sunsetOrange:
        return SunsetOrangeColorPalette();
      case ColorPalette.midnightPurple:
        return MidnightPurpleColorPalette();
      case ColorPalette.arcticBlue:
        return ArcticBlueColorPalette();
    }
  }

  static List<ColorPalette> get allPalettes => ColorPalette.values;

  static String getPaletteName(ColorPalette palette) {
    return getPalette(palette).name;
  }
}
