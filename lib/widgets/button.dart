import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class DButton extends StatelessWidget {
  const DButton({
    super.key,
    required this.onTap,
    required this.btnTitle,
    required this.width,
    required this.height,
    this.btnColor,
    this.textColor,
    this.showBorder = false,
  });

  final Function()? onTap;
  final String btnTitle;
  final double width, height;
  final Color? btnColor, textColor;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DSizes.buttonRadius),
          color: btnColor ?? DColors.primary,
          border:
              showBorder ? Border.all(color: DColors.primary, width: 2) : null,
        ),
        child: Center(
          child: Text(btnTitle, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
    );
  }
}
