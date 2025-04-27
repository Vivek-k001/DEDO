import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class DButton extends StatelessWidget {
  const DButton({
    super.key,
    this.onTap,
    required this.btnTitle,
    required this.width,
    required this.height,
    this.btnColor,
    this.textColor,
  });

  final Function()? onTap;
  final String btnTitle;
  final double width, height;
  final Color? btnColor, textColor;

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
        ),
        child: Text(btnTitle, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
