import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:flutter/material.dart';

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

  final Function()? onTap;
  final String btnTitle;
  final double width, height;
  final double? borderRadius;
  final Color? btnColor, textColor, iconColor;
  final bool showBorder;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            borderRadius ?? DSizes.buttonRadius,
          ),
          color: btnColor,
          border:
              showBorder ? Border.all(color: DColors.primary, width: 2) : null,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: DSizes.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color:
                      iconColor ??
                      (isDark ? DColors.darkerGrey : DColors.lightGrey),
                  size: 30,
                ),

              if (icon != null) const SizedBox(width: DSizes.md),

              Text(
                btnTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
