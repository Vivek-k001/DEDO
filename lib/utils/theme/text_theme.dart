import 'package:flutter/material.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class DTextTheme {
  DTextTheme._();

  // Light Theme For Text
  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: DColors.dark,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: DColors.dark,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: DColors.dark,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: DColors.dark,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: DColors.dark,
    ),
    titleSmall: GoogleFonts.lato(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      color: DColors.dark,
    ),
    bodyLarge: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: DColors.dark,
    ),
    bodyMedium: GoogleFonts.lato(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      color: DColors.dark,
    ),
    bodySmall: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: DColors.dark.withValues(alpha: 0.5),
    ),
    labelLarge: GoogleFonts.lato(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: DColors.dark,
    ),
    labelMedium: GoogleFonts.lato(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: DColors.dark.withValues(alpha: 0.5),
    ),
  );

  // Dark Theme For Text
  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: DColors.light,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: DColors.light,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: DColors.light,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: DColors.light,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: DColors.light,
    ),
    titleSmall: GoogleFonts.lato(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      color: DColors.light,
    ),
    bodyLarge: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: DColors.light,
    ),
    bodyMedium: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: DColors.light,
    ),
    bodySmall: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: DColors.light.withValues(alpha: 0.5),
    ),
    labelLarge: GoogleFonts.lato(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: DColors.light,
    ),
    labelMedium: GoogleFonts.lato(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: DColors.light.withValues(alpha: 0.5),
    ),
  );
}
