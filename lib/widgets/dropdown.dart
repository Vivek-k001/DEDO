import 'package:dedo/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class DDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final double iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry padding;
  final bool isExpanded;

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
      padding: padding,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          icon: Icon(Icons.arrow_drop_down, size: iconSize, color: iconColor),
          iconSize: iconSize,
          isExpanded: isExpanded,
          style: Theme.of(context).textTheme.bodyMedium,
          elevation: 0,
          borderRadius: BorderRadius.circular(8),
          dropdownColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }
}
