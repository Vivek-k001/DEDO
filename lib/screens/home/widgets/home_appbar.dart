import 'package:dedo/bloc/theme/theme_bloc.dart';
import 'package:dedo/screens/category/category.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/text.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Custom AppBar widget for Home screen implementing PreferredSizeWidget for AppBar sizing
class DHomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  // Constructor
  const DHomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect if dark mode is active via helper function
    final isDark = DHelperFunctions.isDarkMode(context);

    return DAppBar(
      // AppBar title displaying app name with theme headline style
      title: Text(
        DTexts.appName,
        style: Theme.of(context).textTheme.headlineMedium,
      ),

      // Action buttons on the right side of the AppBar
      actions: [
        /// Theme Switcher Button (toggles light/dark mode)
        BlocBuilder<ThemeBloc, ThemeMode>(
          builder: (context, state) {
            return IconButton(
              icon: Icon(
                // Icon changes based on current theme mode
                state == ThemeMode.dark
                    ? Icons.nightlight_round
                    : Icons.wb_sunny,
                // Icon color adjusts for visibility depending on theme
                color: state == ThemeMode.dark ? DColors.light : DColors.dark,
              ),
              onPressed: () async {
                // Dispatch ThemeChangedEvent to toggle theme mode
                context.read<ThemeBloc>().add(
                  ThemeChangedEvent(state == ThemeMode.dark ? false : true),
                );
              },
            );
          },
        ),

        /// Category Screen Icon Button (navigates to Category screen)
        IconButton(
          icon: Icon(
            Icons.category_sharp,
            // Icon color changes based on current theme for contrast
            color: isDark ? DColors.light : DColors.dark,
          ),
          onPressed: () {
            // Navigate to CategoryScreen using helper navigation function
            DHelperFunctions.navigateToScreen(context, const CategoryScreen());
          },
        ),
      ],
    );
  }

  // Required override for PreferredSizeWidget to define AppBar height
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
