import 'package:dedo/utils/constants/sizes.dart';
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
    scaffoldBackgroundColor: DColors.white,
    disabledColor: DColors.lightGrey,
    appBarTheme: DAppbarTheme.lightAppbarTheme,
    textTheme: DTextTheme.lightTextTheme,
    iconTheme: IconThemeData(color: DColors.textPrimary, size: DSizes.iconMd),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: DColors.primary,
    scaffoldBackgroundColor: DColors.black,
    disabledColor: DColors.darkGrey,
    appBarTheme: DAppbarTheme.darkAppbarTheme,
    textTheme: DTextTheme.darkTextTheme,
    iconTheme: IconThemeData(color: DColors.textWhite, size: DSizes.iconMd),
  );
}
