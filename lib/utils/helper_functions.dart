import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DHelperFunctions {
  DHelperFunctions._();

  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size screenSize(context) {
    return MediaQuery.of(context!).size;
  }

  static double screenHeight(context) {
    return MediaQuery.of(context!).size.height;
  }

  static double screenWidth(context) {
    return MediaQuery.of(context!).size.width;
  }

  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd-MMM-yyyy').format(date);
  }
}
