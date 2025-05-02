import 'package:dedo/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class DFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Color backgroundColor;
  final Color selectedColor;
  final Color checkmarkColor;

  const DFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.backgroundColor,
    required this.selectedColor,
    required this.checkmarkColor,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label, style: TextStyle(color: DColors.black)),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: backgroundColor,
      selectedColor: selectedColor,
      checkmarkColor: checkmarkColor,
    );
  }
}
