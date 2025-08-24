import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  static const String _storageKey = 'theme_mode';

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  late final GetStorage _storage;

  static ThemeController get instance => Get.find<ThemeController>();

  @override
  void onInit() {
    super.onInit();
    _storage = GetStorage();
    final String? persisted = _storage.read<String>(_storageKey);
    if (persisted != null) {
      themeMode.value = _stringToThemeMode(persisted);
    }
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _storage.write(_storageKey, _themeModeToString(mode));
  }

  void toggleDarkMode(bool enabled) {
    setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
