import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dedo/utils/constants/sizes.dart';

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

  static void showAlert(String title, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showSnackBar({
    required String title,
    required String message,
    required IconData icon,
    required BuildContext context,
    Color bgColor = Colors.red,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(DSizes.sm),
          height: 80,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(DSizes.sm),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 40),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge!.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: DSizes.xs),
                    Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall!.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        elevation: 3,
      ),
    );
  }
}
