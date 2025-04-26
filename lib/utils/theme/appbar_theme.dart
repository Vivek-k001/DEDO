import 'package:dedo/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class DAppbarTheme {
  DAppbarTheme._();

  // Light Theme For Appbar
  static const lightAppbarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.black, size: DSizes.iconMd),
    actionsIconTheme: IconThemeData(color: Colors.black, size: DSizes.iconMd),
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
  );

  // Dark Theme For Appbar
  static const darkAppbarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.black, size: DSizes.iconMd),
    actionsIconTheme: IconThemeData(color: Colors.white, size: DSizes.iconMd),
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  );
}
