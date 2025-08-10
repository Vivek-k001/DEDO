import 'package:dedo/screens/task_form/add_task.dart';
import 'package:dedo/screens/home/home.dart';
import 'package:dedo/screens/profile/profile.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';

/// Main page that serves as the entry point of the app
/// Contains a bottom navigation bar to switch between Home and Profile screens
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Current index of the selected tab in bottom navigation
  int currentIndex = 0;

  // List of screens corresponding to the bottom navbar tabs
  final List<Widget> _screens = [HomeScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Floating Action Button to add a new task
      floatingActionButton: FloatingActionButton(
        backgroundColor: DColors.primary,
        onPressed:
            () => DHelperFunctions.navigateToScreen(
              context,
              const AddTaskScreen(),
            ), // Navigate to AddTaskScreen on press
        tooltip: "Add Task",
        child: const Icon(Icons.add, color: DColors.dark),
      ),

      // Custom Bottom Navigation Bar widget
      bottomNavigationBar: DBottomNavbar(
        currentIndex: currentIndex,
        onIndexChange: (index) => setState(() => currentIndex = index),
        // Update the selected tab index when user taps on a tab
      ),

      // Display the screen corresponding to the selected tab
      body: _screens[currentIndex],
    );
  }
}
