import 'package:dedo/widgets/container.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dedo/utils/constants/sizes.dart';

/// A collection of static utility/helper functions used across the app.
class DHelperFunctions {
  DHelperFunctions._(); // Private constructor to prevent instantiation

  /// Navigate to a new screen using [MaterialPageRoute]
  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  /// Returns true if the current theme is in dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Returns full screen size
  static Size screenSize(context) {
    return MediaQuery.of(context).size;
  }

  /// Returns screen height
  static double screenHeight(context) {
    return MediaQuery.of(context).size.height;
  }

  /// Returns screen width
  static double screenWidth(context) {
    return MediaQuery.of(context).size.width;
  }

  /// Formats a given [DateTime] into a human-readable string
  /// Format: dd-MMM-yyyy (e.g., 04-Jun-2025)
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  /// Shows a simple alert dialog with [title] and [message]
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

  /// Displays a custom SnackBar with an icon, message and optional [action]
  static void showSnackBar({
    required String title,
    required String message,
    required IconData icon,
    required BuildContext context,
    required Color bgColor,
    Duration duration = const Duration(seconds: 1),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: DContainer(
          padding: const EdgeInsets.all(DSizes.sm),
          width: double.infinity,
          height: 80,
          backgroundColor: bgColor,
          borderRadius: BorderRadius.circular(DSizes.sm),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 40),
              const SizedBox(width: 20),
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
                      ).textTheme.bodyMedium!.copyWith(color: Colors.white70),
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
        elevation: 0,
      ),
    );
  }
}
