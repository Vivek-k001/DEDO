import 'package:flutter/material.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/constants/colors.dart';

class DAppbarTheme {
  DAppbarTheme._();

  // Light Theme for Appbar
  static const lightAppbarTheme = AppBarTheme(
    elevation: 2,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: DColors.light,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: DColors.textPrimary, size: DSizes.iconMd),
  );

  // Dark Theme For Appbar
  static const darkAppbarTheme = AppBarTheme(
    elevation: 2,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.black, size: DSizes.iconMd),
  );
}
