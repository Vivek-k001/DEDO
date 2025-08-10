import 'package:flutter/material.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class DTextTheme {
  // Private constructor to prevent instantiation
  DTextTheme._();

  // Light Theme For Text
  static TextTheme lightTextTheme = TextTheme(
    // Large headline style, bold Poppins font, size 32
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: DColors.dark,
    ),
    // Medium headline style, semi-bold Poppins font, size 24
    headlineMedium: GoogleFonts.poppins(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: DColors.dark,
    ),
    // Small headline style, semi-bold Poppins font, size 20
    headlineSmall: GoogleFonts.poppins(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: DColors.dark,
    ),
    // Large title style, semi-bold Poppins font, size 18
    titleLarge: GoogleFonts.poppins(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: DColors.dark,
    ),
    // Medium title style, semi-bold Poppins font, size 16
    titleMedium: GoogleFonts.poppins(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: DColors.dark,
    ),
    // Small title style, medium weight Lato font, size 16
    titleSmall: GoogleFonts.lato(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: DColors.dark,
    ),
    // Large body text, semi-bold Lato font, size 14
    bodyLarge: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      color: DColors.dark,
    ),
    // Medium body text, medium weight Lato font, size 14
    bodyMedium: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: DColors.dark,
    ),
    // Small body text, normal weight Lato font, size 14
    bodySmall: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: DColors.dark,
    ),
    // Large label text, semi-bold Lato font, size 12
    labelLarge: GoogleFonts.lato(
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
      color: DColors.dark,
    ),
    // Medium label text, normal weight Lato font, size 12
    labelMedium: GoogleFonts.lato(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: DColors.dark,
    ),
    // Small label text, normal weight Lato font, size 10
    labelSmall: GoogleFonts.lato(
      fontSize: 10.0,
      fontWeight: FontWeight.normal,
      color: DColors.dark,
    ),
  );

  // Dark Theme For Text
  static TextTheme darkTextTheme = TextTheme(
    // Large headline style, bold Poppins font, size 32
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: DColors.light,
    ),
    // Medium headline style, semi-bold Poppins font, size 24
    headlineMedium: GoogleFonts.poppins(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: DColors.light,
    ),
    // Small headline style, semi-bold Poppins font, size 20
    headlineSmall: GoogleFonts.poppins(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: DColors.light,
    ),
    // Large title style, semi-bold Poppins font, size 18
    titleLarge: GoogleFonts.poppins(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: DColors.light,
    ),
    // Medium title style, semi-bold Poppins font, size 16
    titleMedium: GoogleFonts.poppins(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: DColors.light,
    ),
    // Small title style, medium weight Lato font, size 16
    titleSmall: GoogleFonts.lato(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: DColors.light,
    ),
    // Large body text, semi-bold Lato font, size 14
    bodyLarge: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      color: DColors.light,
    ),
    // Medium body text, medium weight Lato font, size 14
    bodyMedium: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: DColors.light,
    ),
    // Small body text, normal weight Lato font, size 14
    bodySmall: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: DColors.light,
    ),
    // Large label text, semi-bold Lato font, size 12
    labelLarge: GoogleFonts.lato(
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
      color: DColors.light,
    ),
    // Medium label text, normal weight Lato font, size 12
    labelMedium: GoogleFonts.lato(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: DColors.light,
    ),
    // Small label text, normal weight Lato font, size 10
    labelSmall: GoogleFonts.lato(
      fontSize: 10.0,
      fontWeight: FontWeight.normal,
      color: DColors.light,
    ),
  );
}
