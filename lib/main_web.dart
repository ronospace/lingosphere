// 🌐 LingoSphere Web Version - Without Firebase dependencies
// Simplified version for web testing

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/presentation/home_screen.dart';
import 'shared/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: LingoSphereWebApp()));
}

class LingoSphereWebApp extends StatelessWidget {
  const LingoSphereWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LingoSphere',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
