import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../services/icon_switcher_service.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier()
      : super(HiveService.isDarkMode() ? ThemeMode.dark : ThemeMode.light) {
    // Synchronize launcher app icon on app launch
    IconSwitcherService.updateIcon(isDark: HiveService.isDarkMode());
  }

  void toggle() {
    final newMode =
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    final isDark = newMode == ThemeMode.dark;
    HiveService.setDarkMode(isDark);
    IconSwitcherService.updateIcon(isDark: isDark);
  }

  void syncWithPlatformBrightness(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    if (state != (isDark ? ThemeMode.dark : ThemeMode.light)) {
      state = isDark ? ThemeMode.dark : ThemeMode.light;
      HiveService.setDarkMode(isDark);
    }
    IconSwitcherService.updateIcon(isDark: isDark);
  }

  bool get isDark => state == ThemeMode.dark;
}
