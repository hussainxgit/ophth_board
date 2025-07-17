import 'package:flutter/material.dart';

class ThemeState {
  final ColorPalette colorPalette;
  final ThemeMode themeMode;

  const ThemeState({
    this.colorPalette = ColorPalette.arcticBlue,
    this.themeMode = ThemeMode.system,
  });

  ThemeState copyWith({ColorPalette? colorPalette, ThemeMode? themeMode}) {
    return ThemeState(
      colorPalette: colorPalette ?? this.colorPalette,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState &&
        other.colorPalette == colorPalette &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode => colorPalette.hashCode ^ themeMode.hashCode;
}

enum ColorPalette {
  arcticBlue,
  emeraldGreen,
  sunsetOrange,
  royalPurple,
  crimsonRed,
}

extension ColorPaletteExtension on ColorPalette {
  String get displayName {
    switch (this) {
      case ColorPalette.arcticBlue:
        return 'Arctic Blue';
      case ColorPalette.emeraldGreen:
        return 'Emerald Green';
      case ColorPalette.sunsetOrange:
        return 'Sunset Orange';
      case ColorPalette.royalPurple:
        return 'Royal Purple';
      case ColorPalette.crimsonRed:
        return 'Crimson Red';
    }
  }
}
