import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:flutter/material.dart';

class DFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Color backgroundColor;
  final Color selectedColor;
  final Color? checkmarkColor;
  final Color selectedTextColor;

  const DFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.backgroundColor,
    required this.selectedColor,
    this.checkmarkColor,
    required this.selectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return FilterChip(
      label: Text(label),
      labelStyle: TextStyle(
        color:
            isSelected
                ? selectedTextColor
                : (isDark ? DColors.light : DColors.dark),
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: backgroundColor,
      selectedColor: selectedColor,
      checkmarkColor: checkmarkColor,
      showCheckmark: false,
    );
  }
}
