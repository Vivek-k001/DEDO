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
    this.showShadow = false,
    this.autofocus = false,
    this.textCapitalization,
    this.textInputAction,
    this.onFieldSubmitted,
    this.maxLength,
    this.contentPadding,
  });

  // Controller to manage the text inside the form field
  final TextEditingController? controller;

  // Placeholder text shown when input is empty
  final String hintText;

  // Label title shown above the input field
  final String title;

  // Icon displayed at the start (left) of the input
  final IconData prefixIcon;

  // Optional icon displayed at the end (right) of the input
  final IconData? suffixIcon;

  // Background fill color for the input container
  final Color? fillColor;

  // Keyboard type to control input type (e.g. text, number, email)
  final TextInputType? keyboardType;

  // If true, the input field is read-only (disabled for editing)
  final bool readOnly;

  // Controls vertical density of the input field (true means less vertical padding)
  final bool isDense;

  // Optional callback when the input field is tapped
  final VoidCallback? onTap;

  // Optional callback for suffix icon press
  final VoidCallback? onIconPressed;

  // Callback fired when input text changes
  final ValueChanged<String>? onChanged;

  // Optional custom widget to show as suffix instead of suffixIcon
  final Widget? suffixWidget;

  // Height of the input field container
  final double height;

  // Maximum lines for input text, defaults to 1 (single line)
  final int maxlines;

  // Optional validator function for form validation
  final String? Function(String?)? validator;
  // BoxShadow if true
  final bool showShadow;

  // Whether to autofocus the input field when the widget is built
  final bool autofocus;

  // Text capitalization style (e.g. none, words, sentences)
  final TextCapitalization? textCapitalization;

  // Text input action (e.g. done, next) for keyboard
  final TextInputAction? textInputAction;

  // Callback when the field is submitted (e.g. on pressing enter)
  final ValueChanged<String>? onFieldSubmitted;

  // Optional maximum length of input text
  final int? maxLength;

  // Padding inside the input field
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    // Determine if dark mode is enabled
    final isDark = DHelperFunctions.isDarkMode(context);

    // Cursor color depends on theme
    final cursorColor = isDark ? Color(0xFFAAB2FA) : Color(0xFFAAB2FA);

    return Padding(
      // Vertical padding around the entire field
      padding: const EdgeInsets.symmetric(vertical: DSizes.sm + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show title text above input if not empty
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

          // Animated container to smoothly adjust height when maxlines change
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            // If multiple lines, increase height accordingly, else use default
            height: maxlines > 1 ? height * maxlines * 0.7 : height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DSizes.borderRadiusLg),
              boxShadow:
                  showShadow
                      ? [
                        BoxShadow(
                          color:
                              isDark
                                  ? const Color(0xA0B8BDFF)
                                  : const Color(0xFFE4ECFF),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : [],
            ),

            // The actual text input field
            child: TextFormField(
              onTap: onTap,
              readOnly: readOnly,
              autofocus: autofocus,
              controller: controller,
              maxLines: maxlines,
              keyboardType: keyboardType,
              cursorColor: cursorColor,
              textAlignVertical: TextAlignVertical.center,
              onChanged: onChanged,
              validator: validator,
              textCapitalization: textCapitalization ?? TextCapitalization.none,
              textInputAction: textInputAction,
              onFieldSubmitted: onFieldSubmitted,
              maxLength: maxLength,

              // Text style based on theme (dark/light)
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

                counterText: '',

                isDense: isDense,

                // Prefix icon wrapped with horizontal padding
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DSizes.sm),
                  child: Icon(
                    prefixIcon,
                    size: 18,
                    color: isDark ? DColors.grey : DColors.darkerGrey,
                  ),
                ),

                // Suffix icon or custom widget, with padding and optional onPressed callback
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

                // Border styles for different states of the input
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

                // Padding inside the input field (horizontal and vertical)
                contentPadding:
                    contentPadding ??
                    EdgeInsets.symmetric(
                      horizontal: DSizes.md,
                      vertical: maxlines > 1 ? DSizes.md : DSizes.sm,
                    ),

                // Fill the background with color depending on theme or provided fillColor
                filled: true,
                fillColor:
                    fillColor ??
                    (isDark ? DColors.darkGrey : DColors.lightGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
