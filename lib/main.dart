import 'package:flutter/material.dart';
import 'design_system/design_system.dart';
import 'design_system/showcase_screen.dart';

void main() {
  runApp(const EasyIeltsApp());
}

class EasyIeltsApp extends StatefulWidget {
  const EasyIeltsApp({super.key});

  @override
  State<EasyIeltsApp> createState() => _EasyIeltsAppState();
}

class _EasyIeltsAppState extends State<EasyIeltsApp> {
  final ThemeController _themeController = ThemeController(ThemeMode.dark);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeController,
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'Easy IELTS Design System',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: DSShowcaseScreen(themeController: _themeController),
        );
      },
    );
  }
}
