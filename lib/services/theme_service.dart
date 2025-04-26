import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  final _box = GetStorage();
  final _key = "isDarkMode";

  bool _getThemeFromBox() => _box.read(_key) ?? false;
  ThemeMode get theme => _getThemeFromBox() ? ThemeMode.dark : ThemeMode.light;
}
