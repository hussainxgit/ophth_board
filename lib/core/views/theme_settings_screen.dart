// lib/core/theme/views/theme_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/theme_state.dart';
import '../providers/theme_providers.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeStateProvider);
    final themeNotifier = ref.read(themeStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Mode Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.brightness_6,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Appearance',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text('System'),
                          icon: Icon(Icons.settings_system_daydream),
                        ),
                      ],
                      selected: {themeState.themeMode},
                      onSelectionChanged: (Set<ThemeMode> selection) {
                        themeNotifier.setThemeMode(selection.first);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Color Palette Section
            Text(
              'Color Themes',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose your preferred color palette',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),

            // Color Palette Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: ColorPalette.values.length,
              itemBuilder: (context, index) {
                final palette = ColorPalette.values[index];
                final isSelected = themeState.colorPalette == palette;

                return _PaletteCard(
                  palette: palette,
                  isSelected: isSelected,
                  onTap: () => themeNotifier.setColorPalette(palette),
                );
              },
            ),

            const SizedBox(height: 24),

            // Reset Button
            Center(
              child: OutlinedButton.icon(
                onPressed: () => themeNotifier.resetToDefaults(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset to Defaults'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteCard extends StatelessWidget {
  final ColorPalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaletteCard({
    required this.palette,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = _getPrimaryColor(palette);
    final secondaryColor = _getSecondaryColor(palette);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: colorScheme.surface,
                    ),
                    child: Stack(
                      children: [
                        // Color swatches
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ColorSwatch(color: primaryColor, size: 12),
                              const SizedBox(width: 4),
                              _ColorSwatch(color: secondaryColor, size: 12),
                              const SizedBox(width: 4),
                              _ColorSwatch(
                                color: _getAccentColor(palette),
                                size: 12,
                              ),
                            ],
                          ),
                        ),

                        // Sample UI elements
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 40,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: secondaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: colorScheme.onSurface
                                            .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Palette name and selection indicator
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        palette.displayName,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? primaryColor
                              : colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: primaryColor, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPrimaryColor(ColorPalette palette) {
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

  Color _getSecondaryColor(ColorPalette palette) {
    switch (palette) {
      case ColorPalette.arcticBlue:
        return const Color(0xFF03DAC6);
      case ColorPalette.emeraldGreen:
        return const Color(0xFF81C784);
      case ColorPalette.sunsetOrange:
        return const Color(0xFFFFB74D);
      case ColorPalette.royalPurple:
        return const Color(0xFFCE93D8);
      case ColorPalette.crimsonRed:
        return const Color(0xFFE57373);
    }
  }

  Color _getAccentColor(ColorPalette palette) {
    switch (palette) {
      case ColorPalette.arcticBlue:
        return const Color(0xFF00BCD4);
      case ColorPalette.emeraldGreen:
        return const Color(0xFF8BC34A);
      case ColorPalette.sunsetOrange:
        return const Color(0xFFFFC107);
      case ColorPalette.royalPurple:
        return const Color(0xFF673AB7);
      case ColorPalette.crimsonRed:
        return const Color(0xFFFF5722);
    }
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final double size;

  const _ColorSwatch({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      ),
    );
  }
}
