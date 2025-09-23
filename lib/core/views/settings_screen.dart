import 'package:flutter/material.dart';

import 'theme_settings_screen.dart';
import 'profile_screen.dart';

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
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              subtitle: const Text('Edit your profile information'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Theme & Appearance'),
              subtitle: const Text('Customize app theme and colors'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ThemeSettingsScreen(),
                  ),
                );
              },
            ),
          ),
          // Add more settings sections here as needed
        ],
      ),
    );
  }
}
