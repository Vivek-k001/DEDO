import 'package:dedo/screens/add_task/add_task.dart';
import 'package:dedo/screens/home/home.dart';
import 'package:dedo/screens/profile.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Widget> _screens = [HomePage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: DColors.primary,
        onPressed:
            () => DHelperFunctions.navigateToScreen(
              context,
              const AddTaskScreen(),
            ),
        tooltip: "Add Task",
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: DBottomNavbar(
        currentIndex: currentIndex,
        onIndexChange: (index) => setState(() => currentIndex = index),
      ),

      body: _screens[currentIndex],
    );
  }
}
