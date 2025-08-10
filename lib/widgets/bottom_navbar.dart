import 'dart:ui';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DBottomNavbar extends StatelessWidget {
  const DBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onIndexChange,
  });

  /// The current selected index in the bottom navigation bar
  final int currentIndex;

  /// Callback to handle index changes
  final void Function(int) onIndexChange;

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    // Glass background color
    // final glassBg =
    //     isDark
    //         ? Colors.black.withValues(alpha: 0.4)
    //         : Colors.white.withValues(alpha: 0.4);

    // Border color
    final borderColor =
        isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.10);

    // Indicator color
    final indicatorColor = DColors.primary.withValues(alpha: 0.2);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: DContainer(
          height: 80,
          backgroundColor: Colors.transparent,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: borderColor, width: 1.2),
          child: NavigationBar(
            height: 80,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: indicatorColor,
            selectedIndex: currentIndex,
            onDestinationSelected: onIndexChange,
            destinations: const [
              NavigationDestination(
                icon: Icon(CupertinoIcons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(CupertinoIcons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
