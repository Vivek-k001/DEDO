import 'package:flutter/material.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/constants/colors.dart';

class DAppbarTheme {
  DAppbarTheme._();

  // Light Theme for Appbar
  static const lightAppbarTheme = AppBarTheme(
    elevation: 2,
    centerTitle: true,
    scrolledUnderElevation: 0,
    backgroundColor: DColors.light,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: DColors.textPrimary, size: DSizes.iconMd),
  );

  // Dark Theme For Appbar
  static const darkAppbarTheme = AppBarTheme(
    elevation: 2,
    centerTitle: true,
    scrolledUnderElevation: 0,
    backgroundColor: DColors.dark,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: DColors.textWhite, size: DSizes.iconMd),
  );
}
