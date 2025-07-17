// lib/core/theme/services/theme_service.dart
import '../models/theme_state.dart';
import '../repositories/theme_repository.dart';

class ThemeService {
  final ThemeRepository _repository;

  const ThemeService(this._repository);

  Future<ThemeState?> loadTheme() => _repository.loadTheme();

  Future<void> saveTheme(ThemeState themeState) =>
      _repository.saveTheme(themeState);

  List<ColorPalette> get availablePalettes => ColorPalette.values;

  String getPaletteName(ColorPalette palette) => palette.displayName;
}
