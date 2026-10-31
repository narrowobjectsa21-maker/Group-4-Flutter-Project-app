import 'package:flutter/material.dart';

import 'data/project_store.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(OrbitApp(store: ProjectStore()));
}

/// The root of the app: one MaterialApp, one theme, Home screen first.
class OrbitApp extends StatelessWidget {
  const OrbitApp({super.key, required this.store});

  /// All project data. It is handed down to every screen.
  final ProjectStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orbit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: HomeScreen(store: store),
    );
  }
}
