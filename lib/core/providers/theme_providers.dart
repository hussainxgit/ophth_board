// lib/core/theme/providers/theme_providers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/theme_state.dart';
import '../repositories/theme_repository.dart';
import '../services/theme_service.dart';
import '../theme/dynamic_app_theme.dart';

// Repository for theme persistence
final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepository();
});

// Service for theme operations
final themeServiceProvider = Provider<ThemeService>((ref) {
  final repository = ref.watch(themeRepositoryProvider);
  return ThemeService(repository);
});

// Main theme state provider
final themeStateProvider =
    StateNotifierProvider<ThemeStateNotifier, ThemeState>((ref) {
      final service = ref.watch(themeServiceProvider);
      return ThemeStateNotifier(service);
    });

// Computed providers for theme data
final lightThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeStateProvider);
  return DynamicAppTheme.getLightTheme(themeState.colorPalette);
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeStateProvider);
  return DynamicAppTheme.getDarkTheme(themeState.colorPalette);
});

// Current theme based on system/selected mode
final currentThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeStateProvider);
  final brightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  final isDark = switch (themeState.themeMode) {
    ThemeMode.dark => true,
    ThemeMode.light => false,
    ThemeMode.system => brightness == Brightness.dark,
  };

  return isDark ? ref.watch(darkThemeProvider) : ref.watch(lightThemeProvider);
});

// Theme state notifier
class ThemeStateNotifier extends StateNotifier<ThemeState> {
  final ThemeService _service;

  ThemeStateNotifier(this._service) : super(const ThemeState()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedState = await _service.loadTheme();
    if (savedState != null) {
      state = savedState;
    }
  }

  Future<void> setColorPalette(ColorPalette palette) async {
    final newState = state.copyWith(colorPalette: palette);
    state = newState;
    await _service.saveTheme(newState);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final newState = state.copyWith(themeMode: mode);
    state = newState;
    await _service.saveTheme(newState);
  }

  Future<void> resetToDefaults() async {
    const defaultState = ThemeState();
    state = defaultState;
    await _service.saveTheme(defaultState);
  }
}
