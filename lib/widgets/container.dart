import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:flutter/material.dart';

/// A customizable container widget with options for background, padding,
/// margin, border, shape, shadow, size, and child widget.
class DContainer extends StatelessWidget {
  final Widget child; // The widget inside the container
  final Color? backgroundColor; // Background color override
  final EdgeInsetsGeometry? padding; // Inner padding
  final EdgeInsetsGeometry? margin; // Outer margin
  final BorderRadiusGeometry? borderRadius; // Rounded corners for rectangle shape
  final BoxBorder? border; // Border around container
  final double? height; // Fixed height
  final double? width; // Fixed width
  final List<BoxShadow>? boxShadow; // Shadow effects
  final BoxShape? shape; // Shape of container (rectangle or circle)

  const DContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
    this.height,
    this.width,
    this.boxShadow,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    final effectiveShape = shape ?? BoxShape.rectangle;

    final effectiveBorderRadius =
        effectiveShape == BoxShape.circle
            ? null
            : (borderRadius ?? BorderRadius.circular(DSizes.sm));

    return Container(
      height: height,
      width: width,
      padding: padding ?? const EdgeInsets.all(DSizes.xs), // Default padding if none
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? DColors.darkGrey : DColors.light), // Default bg color based on theme
        borderRadius: effectiveBorderRadius,
        border:
            border ?? // Use provided border or default border with color based on theme
            Border.all(
              color: isDark ? DColors.dark : DColors.lightGrey,
              width: effectiveShape == BoxShape.circle ? 1.5 : 1.0,
            ),
        boxShadow: boxShadow, // Optional shadow list
        shape: effectiveShape,
      ),
      child: child,
    );
  }
}
