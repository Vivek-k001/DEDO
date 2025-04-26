import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/theme/appbar_theme.dart';
import 'package:flutter/material.dart';

class DAppTheme {
  DAppTheme._();

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: DColors.primary,
    disabledColor: DColors.grey,
    scaffoldBackgroundColor: DColors.light,
    appBarTheme: DAppbarTheme.lightAppbarTheme,
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: DColors.primary,
    scaffoldBackgroundColor: DColors.dark,
    appBarTheme: DAppbarTheme.darkAppbarTheme,
  );
}
