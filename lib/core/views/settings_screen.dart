import 'package:flutter/material.dart';

import 'theme_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Theme & Appearance'),
            subtitle: const Text('Customize app theme and colors'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
              );
            },
          ),
          // Add more settings sections here as needed
        ],
      ),
    );
  }
}
