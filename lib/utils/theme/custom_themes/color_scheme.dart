import 'package:flutter/material.dart';
import '../../constants/colors.dart';

ColorScheme buildLightColorScheme() {
  return const ColorScheme(
    brightness: Brightness.light,
    primary: RColors.primary,
    onPrimary: Colors.white,
    secondary: RColors.secondary,
    onSecondary: Colors.black,
    error: RColors.error,
    onError: Colors.white,
    background: Colors.white,
    onBackground: RColors.textPrimary,
    surface: Colors.white,
    onSurface: RColors.textPrimary,
  );
}

ColorScheme buildDarkColorScheme() {
  return const ColorScheme(
    brightness: Brightness.dark,
    primary: RColors.primary,
    onPrimary: Colors.white,
    secondary: RColors.accent,
    onSecondary: Colors.black,
    error: RColors.error,
    onError: Colors.white,
    background: Color(0xFF0E0F11),
    onBackground: Colors.white,
    surface: Color(0xFF131417),
    onSurface: Colors.white,
  );
}
