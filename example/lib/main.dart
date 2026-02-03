import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : _themeMode == ThemeMode.dark
              ? ThemeMode.system
              : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Pagination Pro Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      builder: (context, child) {
        // Add theme toggle button to all screens
        return Stack(
          children: [
            child!,
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 8,
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Icon(
                      _themeMode == ThemeMode.light
                          ? Icons.light_mode
                          : _themeMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : Icons.brightness_auto,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: _themeMode == ThemeMode.light
                        ? 'Switch to Dark Mode'
                        : _themeMode == ThemeMode.dark
                            ? 'Switch to System Mode'
                            : 'Switch to Light Mode',
                    onPressed: _toggleTheme,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      home: const HomeScreen(),
    );
  }
}
