import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:flutter/material.dart';

class DTextFormField extends StatelessWidget {
  const DTextFormField({
    super.key,
    this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.title,
    this.suffixIcon,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.onIconPressed,
    this.fillColor,
    this.isDense = false,
    this.suffixWidget,
    this.onChanged,
    this.height = 50,
  });

  final TextEditingController? controller;
  final String hintText, title;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final Color? fillColor;
  final TextInputType? keyboardType;
  final bool readOnly, isDense;
  final VoidCallback? onTap;
  final VoidCallback? onIconPressed;
  final ValueChanged<String>? onChanged;
  final Widget? suffixWidget;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSizes.sm + 2),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: DSizes.sm),
          SizedBox(
            height: height,
            child: TextFormField(
              onTap: onTap,
              readOnly: readOnly,
              autofocus: false,
              controller: controller,
              keyboardType: keyboardType,
              cursorColor: isDark ? Colors.grey[100] : Colors.grey[800],
              textAlignVertical: TextAlignVertical.center,
              onChanged: onChanged,
              style: Theme.of(context).textTheme.bodySmall,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: Theme.of(context).textTheme.bodySmall,
                isDense: isDense,
                prefixIcon: Icon(prefixIcon, size: 16, color: Colors.grey),
                suffixIcon:
                    suffixWidget ??
                    (suffixIcon != null
                        ? IconButton(
                          onPressed: onIconPressed,
                          icon: Icon(suffixIcon, size: 16, color: Colors.grey),
                        )
                        : null),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: fillColor ?? (isDark ? DColors.dark : DColors.light),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
