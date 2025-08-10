import 'package:dedo/bloc/category/category_bloc.dart';
import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/models/category_model.dart';
import 'package:dedo/models/task_model.dart';
import 'package:dedo/screens/category/category_detail.dart';
import 'package:dedo/screens/home/widgets/category_container.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Widget that displays a horizontal list of categories with progress info.
/// Handles loading, error, and empty states using BlocBuilder.
class DCategoryListSection extends StatelessWidget {
  const DCategoryListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    // BlocBuilder listens to category state to display categories or loading/error UI
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          // Show loading spinner while categories load
          return SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CategoryError) {
          // Show error message if categories failed to load
          return SizedBox(
            height: 100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red),
                  const SizedBox(height: DSizes.sm),
                  Text(
                    state.message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        }

        // Safely extract categories from successful states
        List<CategoryModel> categories = [];
        if (state is CategoryLoaded) {
          categories = state.categories;
        } else if (state is CategorySuccess) {
          categories = state.categories;
        }

        if (categories.isEmpty) {
          // Show placeholder if no categories exist
          return SizedBox(
            height: 100,
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 40,
                    color:
                        isDark
                            ? DColors.grey
                            : DColors.darkGrey.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: DSizes.sm),
                  Text(
                    'No categories found',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color:
                          isDark
                              ? DColors.grey
                              : DColors.darkGrey.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Nested BlocBuilder to get tasks for displaying category progress info
        return BlocBuilder<TaskBloc, TaskState>(
          builder: (context, taskState) {
            List<TaskModel> tasks = [];
            if (taskState is TaskDataLoaded) {
              tasks = taskState.tasks;
            } else if (taskState is TaskSuccess) {
              tasks = taskState.tasks;
            }

            // Horizontal scrollable list showing category containers with task completion stats
            return SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  // Filter tasks that belong to this category
                  final categoryTasks =
                      tasks
                          .where((task) => task.categoryId == category.id)
                          .toList();

                  final totalTasks = categoryTasks.length;

                  // Count how many tasks are completed for progress indicator
                  final completedTasks =
                      categoryTasks.where((task) => task.isCompleted).length;

                  // Calculate progress ratio to show visually
                  final double progress =
                      totalTasks == 0 ? 0 : completedTasks / totalTasks;

                  return DCategoryContainer(
                    category: category,
                    taskCount: totalTasks,
                    completedTasks: completedTasks,
                    progress: progress,
                    onTap: () {
                      // Navigate to detailed view for tapped category
                      DHelperFunctions.navigateToScreen(
                        context,
                        CategoryDetailScreen(category: category),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
