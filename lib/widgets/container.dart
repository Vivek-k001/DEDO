import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:flutter/material.dart';

class DContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final double? height;
  final double? width;
  final List<BoxShadow>? boxShadow;

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
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return Container(
      height: height,
      width: width,
      padding: padding ?? const EdgeInsets.all(DSizes.xs),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? DColors.dark : DColors.light),
        borderRadius: borderRadius ?? BorderRadius.circular(DSizes.sm),
        border:
            border ??
            Border.all(color: isDark ? DColors.darkGrey : DColors.lightGrey),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
