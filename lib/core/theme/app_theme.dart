import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

class AppTheme {
  static ThemeData get lightTheme => buildLightTheme();
  static ThemeData get darkTheme => buildDarkTheme();
}
