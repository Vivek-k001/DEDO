import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/bloc/theme/theme_bloc.dart';
import 'package:dedo/screens/profile/widgets/about_section.dart';
import 'package:dedo/screens/profile/widgets/analytics.dart';
import 'package:dedo/screens/profile/widgets/profile_header.dart';
import 'package:dedo/screens/profile/widgets/settings_section.dart';
import 'package:dedo/screens/profile/widgets/statistics_section.dart';
import 'package:dedo/screens/profile/widgets/trend_chart_section.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/widgets/appbar.dart';
import 'package:dedo/widgets/container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Local state for toggles
  late bool _darkModeEnabled;

  @override
  void initState() {
    super.initState();
    // Load profile related data when the screen initializes
    _loadProfileData();

    final themeMode = context.read<ThemeBloc>().state;
    _darkModeEnabled = themeMode == ThemeMode.dark;
  }

  // Method to trigger loading of task-related data from the TaskBloc
  void _loadProfileData() {
    final taskBloc = context.read<TaskBloc>();
    taskBloc.add(LoadTasks()); // Load all tasks
    taskBloc.add(LoadWeeklyStats()); // Load weekly stats for tasks
    taskBloc.add(LoadStreak()); // Load user's task streak days
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DAppBar(
        title: Text(
          "Profile",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfileData, // Reload data on pressing refresh
            tooltip: 'Refresh Data',
          ),
        ],
      ),

      // Listen to TaskBloc state and rebuild UI accordingly
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          // Default values before data loads
          int completedTasks = 0;
          int pendingTasks = 0;
          int totalTasks = 0;
          int streakDays = 0;
          List<double> weeklyStats = List.filled(7, 0);

          if (state is TaskDataLoaded) {
            // Extract data from loaded state
            final tasks = state.tasks;
            final stats = state.weeklyStats;
            final streak = state.streakDays;

            completedTasks = tasks.where((task) => task.isCompleted).length;
            pendingTasks = tasks.where((task) => !task.isCompleted).length;
            totalTasks = tasks.length;
            weeklyStats = stats;
            streakDays = streak;
          }

          return RefreshIndicator(
            // Pull to refresh triggers data reload
            onRefresh: () async {
              _loadProfileData();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView(
              padding: const EdgeInsets.all(DSizes.sm),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Profile header widget (user info, avatar etc.)
                DProfileHeader(),

                const SizedBox(height: DSizes.md),

                // Show error message if TaskError state
                if (state is TaskError) _buildErrorMessage(state.message),

                // Show loading spinner while loading
                if (state is TaskLoading)
                  const Center(child: CircularProgressIndicator()),

                // Show statistics section with task counts and streak
                DStatisticsSection(
                  completed: completedTasks,
                  pending: pendingTasks,
                  streak: streakDays,
                  total: totalTasks,
                ),

                const SizedBox(height: DSizes.md),

                // Show trend chart only when data is loaded
                if (state is TaskDataLoaded)
                  DTrendChartSection(weeklyStats: state.weeklyStats),

                const SizedBox(height: DSizes.md),

                // Show analytics widget summarizing completed tasks
                DAnalytics(
                  completed: completedTasks,
                  total: totalTasks,
                  weeklyStats: weeklyStats,
                ),

                const SizedBox(height: DSizes.md),

                // Settings toggles for notifications and dark mode
                DSettingsSection(
                  darkModeEnabled: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() => _darkModeEnabled = value);
                    context.read<ThemeBloc>().add(ThemeChangedEvent(value));
                  },
                ),

                const SizedBox(height: DSizes.md),

                // About section with app info, version etc.
                AboutSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget to show an error message box with a red border and icon
  Widget _buildErrorMessage(String errorMessage) {
    return DContainer(
      margin: const EdgeInsets.symmetric(vertical: DSizes.sm),
      padding: const EdgeInsets.all(DSizes.md),
      backgroundColor: Colors.red.withValues(
        alpha: 0.1,
      ), // Light red background
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: Colors.red.withValues(alpha: 0.3),
      ), // Red border with transparency
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: DSizes.sm),
          Expanded(
            child: Text(
              errorMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
