import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DBottomNavbar extends StatelessWidget {
  const DBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onIndexChange,
  });

  final int currentIndex;
  final void Function(int) onIndexChange;

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      child: NavigationBar(
        height: 80,
        indicatorColor: DColors.primary,
        backgroundColor: isDark ? DColors.darkerGrey : DColors.lightGrey,
        elevation: 3,
        selectedIndex: currentIndex,
        onDestinationSelected: onIndexChange,
        destinations: const [
          NavigationDestination(
            icon: Icon(CupertinoIcons.home, color: DColors.black),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.person_2_fill, color: DColors.dark),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
