import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class IconSwitcherService {
  static const MethodChannel _channel =
      MethodChannel('com.example.dedo/icon_switcher');

  /// Switches the Android launcher icon to match the theme (Dark / Light).
  static Future<void> updateIcon({required bool isDark}) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('switchIcon', isDark ? 'dark' : 'light');
    } catch (e) {
      debugPrint('IconSwitcherService: Error updating app icon: $e');
    }
  }

  /// Retrieves the currently active icon theme alias ('dark' or 'light').
  static Future<String> getCurrentIcon() async {
    if (kIsWeb || !Platform.isAndroid) return 'dark';
    try {
      final res = await _channel.invokeMethod<String>('getCurrentIcon');
      return res ?? 'dark';
    } catch (e) {
      return 'dark';
    }
  }
}
