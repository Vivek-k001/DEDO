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
    this.height = 52,
    this.maxlines = 1,
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
  final int maxlines;

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);
    final cursorColor = isDark ? DColors.light : DColors.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSizes.sm + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: DSizes.sm),
          SizedBox(
            height: height,
            child: TextFormField(
              onTap: onTap,
              readOnly: readOnly,
              autofocus: false,
              controller: controller,
              maxLines: maxlines,
              keyboardType: keyboardType,
              cursorColor: cursorColor,
              textAlignVertical: TextAlignVertical.center,
              onChanged: onChanged,
              style: Theme.of(context).textTheme.bodySmall,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      isDark
                          ? DColors.light.withValues(alpha: 0.7)
                          : DColors.dark.withValues(alpha: 0.7),
                ),
                isDense: isDense,
                prefixIcon: Icon(prefixIcon, size: 18, color: Colors.grey),
                suffixIcon:
                    suffixWidget ??
                    (suffixIcon != null
                        ? IconButton(
                          onPressed: onIconPressed,
                          icon: Icon(suffixIcon, size: 18, color: Colors.grey),
                        )
                        : null),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DSizes.borderRadiusLg),
                  borderSide: const BorderSide(color: DColors.borderPrimary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: DSizes.md,
                  vertical: DSizes.sm,
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
