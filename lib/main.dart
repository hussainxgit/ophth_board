// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_providers.dart';
import 'core/views/auth/auth_screen.dart';
import 'core/views/main_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeStateProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    final currentUser = ref.watch(currentUserProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ophth Board',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeState.themeMode,
      home: currentUser == null
          ? const AuthScreen()
          : MainScreen(),
    );
  }
}
