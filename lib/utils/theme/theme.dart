import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/theme/appbar_theme.dart';

class DAppTheme {
  // Private constructor to prevent instantiation
  DAppTheme._();

  // Light Theme configuration
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true, // Use Material Design 3
    fontFamily: 'Poppins', // Set default font family
    brightness: Brightness.light, // Light mode brightness
    primaryColor: DColors.primary, // Primary color for the app
    scaffoldBackgroundColor: DColors.white, // Background color for Scaffold
    disabledColor: DColors.lightGrey, // Color used for disabled elements
    appBarTheme: DAppbarTheme.lightAppbarTheme, // Custom AppBar theme for light mode
    textTheme: DTextTheme.lightTextTheme, // Custom text theme for light mode
    iconTheme: IconThemeData(
      color: DColors.textPrimary, // Default icon color
      size: DSizes.iconMd, // Default icon size
    ),
  );

  // Dark Theme configuration
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true, // Use Material Design 3
    fontFamily: 'Poppins', // Set default font family
    brightness: Brightness.dark, // Dark mode brightness
    primaryColor: DColors.primary, // Primary color for the app
    scaffoldBackgroundColor: DColors.black, // Background color for Scaffold
    disabledColor: DColors.darkGrey, // Color used for disabled elements
    appBarTheme: DAppbarTheme.darkAppbarTheme, // Custom AppBar theme for dark mode
    textTheme: DTextTheme.darkTextTheme, // Custom text theme for dark mode
    iconTheme: IconThemeData(
      color: DColors.textWhite, // Default icon color for dark mode
      size: DSizes.iconMd, // Default icon size
    ),
  );
}
