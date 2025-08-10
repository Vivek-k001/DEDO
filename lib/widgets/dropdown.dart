import 'package:dedo/utils/constants/colors.dart';
import 'package:flutter/material.dart';

/// A generic dropdown widget with customizable styling and behavior.
class DDropdown<T> extends StatelessWidget {
  final T? value; // Currently selected value
  final List<DropdownMenuItem<T>> items; // List of dropdown options
  final ValueChanged<T?> onChanged; // Callback when selection changes
  final double iconSize; // Size of dropdown arrow icon
  final Color? iconColor; // Color of dropdown arrow icon
  final EdgeInsetsGeometry padding; // Padding around the dropdown
  final bool isExpanded; // Whether dropdown width expands to fill parent

  const DDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.iconSize = 24.0,
    this.iconColor = DColors.grey,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0),
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding, // Add padding around dropdown
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value, // Currently selected item
          items: items, // List of dropdown items
          onChanged: onChanged, // Selection change callback
          icon: Icon(
            Icons.arrow_drop_down,
            size: iconSize,
            color: iconColor,
          ), // Dropdown arrow icon with size and color
          iconSize: iconSize,
          isExpanded: isExpanded, // Expand to fill width if true
          style: Theme.of(context).textTheme.bodyMedium, // Text style of items
          elevation: 0, // Dropdown menu elevation (shadow)
          borderRadius: BorderRadius.circular(8), // Rounded corners for dropdown menu
          dropdownColor: Theme.of(context).cardColor, // Background color of dropdown menu
        ),
      ),
    );
  }
}
