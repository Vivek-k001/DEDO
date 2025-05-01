import 'package:dedo/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class DDropdown extends StatelessWidget {
  final String value;
  final List<DropdownMenuItem<String>> items;
  final Function(String?) onChanged;

  const DDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      icon: const Icon(Icons.keyboard_arrow_down, color: DColors.grey),
      iconSize: 24,
      elevation: 4,
      style: Theme.of(context).textTheme.bodyMedium,
      underline: Container(height: 0),
      onChanged: onChanged,
      items: items,
    );
  }
}
