import 'package:flutter/material.dart';

ThemeData buildDarkTheme() {
  const fontFamily = 'Roboto';
  const primary = Color(0xFFD97757);
  const background = Color(0xFF1C1C1E);
  const surface = Color(0xFF2C2C2E);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      surface: surface,
      onSurface: Colors.white,
      onPrimary: Colors.white,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: primary),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 16),
      bodySmall: TextStyle(fontSize: 13, color: Color(0xFFABABAB)),
    ),
  );
}
