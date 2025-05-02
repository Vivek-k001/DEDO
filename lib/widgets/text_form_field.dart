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
    this.validator,
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
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);
    final cursorColor = isDark ? DColors.white : DColors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSizes.sm + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: DSizes.xs),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: maxlines > 1 ? height * maxlines * 0.7 : height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DSizes.borderRadiusLg),
              boxShadow: [
                BoxShadow(
                  color:
                      isDark
                          ? Colors.black12
                          : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
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
              validator: validator,

              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? DColors.light : DColors.dark,
              ),

              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      isDark
                          ? DColors.light.withValues(alpha: 0.5)
                          : DColors.dark.withValues(alpha: 0.5),
                ),

                isDense: isDense,

                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DSizes.sm),
                  child: Icon(
                    prefixIcon,
                    size: 18,
                    color: isDark ? DColors.grey : DColors.darkerGrey,
                  ),
                ),
                suffixIcon:
                    suffixWidget ??
                    (suffixIcon != null
                        ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DSizes.sm,
                          ),
                          child: IconButton(
                            onPressed: onIconPressed,
                            icon: Icon(
                              suffixIcon,
                              size: 18,
                              color: isDark ? DColors.grey : DColors.darkerGrey,
                            ),
                          ),
                        )
                        : null),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DSizes.borderRadiusLg),
                  borderSide: BorderSide(
                    color: isDark ? DColors.darkGrey : DColors.lightGrey,
                    width: 1.0,
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DSizes.borderRadiusLg),
                  borderSide: BorderSide(
                    color: isDark ? DColors.darkGrey : DColors.lightGrey,
                    width: 1.0,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DSizes.borderRadiusLg),
                  borderSide: BorderSide(color: DColors.primary, width: 1.5),
                ),

                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DSizes.borderRadiusLg),
                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                ),

                contentPadding: EdgeInsets.symmetric(
                  horizontal: DSizes.md,
                  vertical: maxlines > 1 ? DSizes.md : DSizes.sm,
                ),

                filled: true,
                fillColor:
                    fillColor ??
                    (isDark ? DColors.darkerGrey : DColors.lightGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
