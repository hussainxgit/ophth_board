// Repository for theme persistence
import 'package:flutter/material.dart';
import 'package:ophth_board/core/models/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  static const String _themeModeKey = 'theme_mode';
  static const String _colorPaletteKey = 'color_palette';

  Future<ThemeState?> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeModeIndex = prefs.getInt(_themeModeKey);
      final colorPaletteIndex = prefs.getInt(_colorPaletteKey);

      if (themeModeIndex == null || colorPaletteIndex == null) {
        return null;
      }

      final themeMode = ThemeMode.values[themeModeIndex];
      final colorPalette = ColorPalette.values[colorPaletteIndex];

      return ThemeState(themeMode: themeMode, colorPalette: colorPalette);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveTheme(ThemeState themeState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, themeState.themeMode.index);
      await prefs.setInt(_colorPaletteKey, themeState.colorPalette.index);
    } catch (e) {
      // Handle error appropriately in production
      debugPrint('Failed to save theme: $e');
    }
  }
}
