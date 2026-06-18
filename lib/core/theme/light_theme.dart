import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  const fontFamily = 'Roboto';
  const primary = Color(0xFFD97757);
  const background = Color(0xFFFFFFFF);
  const surface = Color(0xFFF7F7F8);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: fontFamily,
    colorScheme: const ColorScheme.light(
      primary: primary,
      surface: surface,
      onSurface: Color(0xFF1A1A1A),
      onPrimary: Colors.white,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: Color(0xFF1A1A1A),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
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
      bodySmall: TextStyle(fontSize: 13, color: Color(0xFF6B6B6B)),
    ),
  );
}
