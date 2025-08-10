import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:flutter/material.dart';

/// A customizable AppBar widget for the app
class DAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DAppBar({
    super.key,
    this.title,
    this.showBackArrow = false,
    this.leadingIcon,
    this.actions,
    this.leadingOnPressed,
  });

  /// The title widget of the app bar
  final Widget? title;

  /// Whether to show the default back arrow
  final bool showBackArrow;

  /// Optional custom leading icon if back arrow is not shown
  final IconData? leadingIcon;

  /// List of widgets to display in the actions area (right side)
  final List<Widget>? actions;

  /// Callback when the leading icon is pressed
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    final darkMode = DHelperFunctions.isDarkMode(context); // Check for theme mode

    return AppBar(
      automaticallyImplyLeading: false, // Prevent default back button
      titleSpacing: 0,
      leadingWidth: 48,

      // Determine what to show as the leading widget
      leading: showBackArrow
          ? IconButton(
              onPressed: () => Navigator.pop(context), // Go back on press
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: darkMode ? Colors.white : DColors.dark,
              ),
            )
          : leadingIcon != null
              ? IconButton(
                  onPressed: leadingOnPressed, // Trigger custom action
                  icon: Icon(leadingIcon),
                )
              : null,

      title: title,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // Default toolbar height
}
