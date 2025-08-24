import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';

class RChipRheme {
  RChipRheme._();

  static ChipThemeData lightChipRheme = ChipThemeData(
    disabledColor: RColors.grey.withOpacity(0.4),
    labelStyle: const TextStyle(color: RColors.black),
    selectedColor: RColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    checkmarkColor: RColors.white,
  ); // ChipRhemeData

  static ChipThemeData darkChipRheme = const ChipThemeData(
    disabledColor: RColors.darkerGrey,
    labelStyle: TextStyle(color: RColors.white),
    selectedColor: RColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    checkmarkColor: RColors.white,
  ); // ChipRhemeData
}
