import 'package:flutter/material.dart';

class AppTheme {
  static const Color primarySeedColor = Color(0xFF2d5016);
  static const Color scaffoldBackground = Color(0xFF132312);
  static const Color canvasBackground = Color(0xFF132312);
  static const Color appBarBackground = Color(0xFF2d5016);
  static const Color bottomNavBackground = Color(0xFF1a2e0f);
  static const Color cardBackground = Color(0xFF0f3a1a);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: scaffoldBackground,
      canvasColor: canvasBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bottomNavBackground,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: const CardThemeData(
        color: cardBackground,
        elevation: 8,
        margin: EdgeInsets.only(bottom: 12),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white70),
      ),
    );
  }
}
