import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/widgets/container.dart';
import 'package:flutter/material.dart';

/// A customizable button widget with optional icon, border, and color
class DButton extends StatelessWidget {
  const DButton({
    super.key,
    required this.onTap,
    required this.btnTitle,
    required this.width,
    this.height = 50,
    this.btnColor = DColors.primary,
    this.textColor,
    this.showBorder = false,
    this.icon,
    this.borderRadius,
    this.iconColor,
  });

  final Function()? onTap; // Callback when button is tapped
  final String btnTitle; // Text displayed on the button
  final double width, height; // Button size
  final double? borderRadius; // Optional border radius override
  final Color? btnColor, textColor, iconColor; // Colors for button, text, icon
  final bool showBorder; // Whether to show a border around the button
  final IconData? icon; // Optional icon to show before the text

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DContainer(
        width: width,
        height: height,
        borderRadius: BorderRadius.circular(
          borderRadius ?? DSizes.buttonRadius,
        ),
        backgroundColor: btnColor,
        border:
            showBorder
                ? Border.all(color: DColors.primary, width: 2)
                : null, // Optional border
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 200,
          ), // Smooth animation for changes
          padding: const EdgeInsets.symmetric(
            horizontal: DSizes.md,
          ), // Horizontal padding
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center content horizontally
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color: iconColor ?? DColors.black,
                  size: 26,
                ), // Show icon if provided

              if (icon != null)
                const SizedBox(width: DSizes.md), // Space between icon and text

              Text(
                btnTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.black, // Text color fallback
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
