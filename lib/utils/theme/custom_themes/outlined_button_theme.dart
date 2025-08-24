import 'package:flutter/material.dart';

import '../../constants/colors.dart';

/// -- Light & Dark Outlined Button Themes --
class ROutlinedButtonTheme {
  ROutlinedButtonTheme._(); // To avoid creating instances

  /// -- Light Theme --
  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.black,
      side: const BorderSide(color: RColors.primary),
      textStyle: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ); // OutlinedButtonThemeData

  /// -- Dark Theme --
  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      side: const BorderSide(color: RColors.primary),
      textStyle: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ); // OutlinedButtonThemeData
}
