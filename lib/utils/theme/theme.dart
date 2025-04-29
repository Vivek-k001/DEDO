import 'package:dedo/utils/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/theme/appbar_theme.dart';

class DAppTheme {
  DAppTheme._();

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: DColors.primary,
    scaffoldBackgroundColor: DColors.light,
    disabledColor: DColors.grey,
    appBarTheme: DAppbarTheme.lightAppbarTheme,
    textTheme: DTextTheme.lightTextTheme,
    iconTheme: const IconThemeData(color: DColors.textPrimary),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: DColors.primary,
    scaffoldBackgroundColor: DColors.dark,
    disabledColor: DColors.darkGrey,
    appBarTheme: DAppbarTheme.darkAppbarTheme,
    textTheme: DTextTheme.darkTextTheme,
    iconTheme: const IconThemeData(color: DColors.textWhite),
  );
}
