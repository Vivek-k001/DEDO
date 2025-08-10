import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:flutter/material.dart';

/// A custom filter chip widget that supports dark mode and custom colors.
class DFilterChip extends StatelessWidget {
  final String label; // Text label of the chip
  final bool isSelected; // Whether the chip is selected or not
  final ValueChanged<bool> onSelected; // Callback when selection toggles
  final Color backgroundColor; // Background color when not selected
  final Color selectedColor; // Background color when selected
  final Color? checkmarkColor; // Color of the checkmark (if shown)
  final Color selectedTextColor; // Text color when selected

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
        color: isSelected
            ? selectedTextColor // Use selected text color if selected
            : (isDark ? DColors.light : DColors.dark), // Otherwise adjust for dark/light mode
      ),
      selected: isSelected, // Whether chip is selected
      onSelected: onSelected, // Selection toggle callback
      backgroundColor: backgroundColor, // Background color when unselected
      selectedColor: selectedColor, // Background color when selected
      checkmarkColor: checkmarkColor, // Checkmark color (optional)
      showCheckmark: false, // Do not show the checkmark icon
    );
  }
}
