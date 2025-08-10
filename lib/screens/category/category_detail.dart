import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/models/category_model.dart';
import 'package:dedo/models/task_model.dart';
import 'package:dedo/screens/home/widgets/task_bottom_sheet.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/appbar.dart';
import 'package:dedo/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CategoryDetailScreen extends StatelessWidget {
  final CategoryModel category;

  // Constructor requiring a category object
  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return Scaffold(
      // Custom app bar showing back arrow and category name as title
      appBar: DAppBar(
        showBackArrow: true,
        title: Text(
          '${category.name} Tasks',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),

      // BlocBuilder to listen to TaskBloc state changes
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          // Show loading indicator while tasks are loading
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error UI if there is an error state
          if (state is TaskError) {
            return SizedBox(
              height: 100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(height: 8),
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

          // Initialize tasks list
          List<TaskModel> tasks = [];
          if (state is TaskDataLoaded) {
            tasks = state.tasks;
          } else if (state is TaskSuccess) {
            tasks = state.tasks;
          }

          // Show message if there are no tasks at all
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 50,
                    color:
                        isDark
                            ? DColors.grey
                            : DColors.darkGrey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: DSizes.sm),
                  Text(
                    "No tasks found",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color:
                          isDark
                              ? DColors.grey
                              : DColors.darkGrey.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          // Filter tasks to only those matching the selected category
          final filteredTasks =
              tasks.where((task) => task.categoryId == category.id).toList();

          // Show message if no tasks exist in this category
          if (filteredTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 50,
                    color:
                        isDark
                            ? DColors.grey
                            : DColors.darkGrey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: DSizes.sm),
                  Text(
                    'No tasks in this category',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color:
                          isDark
                              ? DColors.grey
                              : DColors.darkGrey.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          // Display the filtered list of tasks with animations and tap handlers
          return Padding(
            padding: const EdgeInsets.all(DSizes.md),
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];

                return AnimationConfiguration.staggeredList(
                  position: index,
                  child: SlideAnimation(
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onTap: () {
                          // Show bottom sheet with task options when tapped
                          taskOptionsBottomSheet(context, task);
                        },
                        child: DTaskTile(
                          title: task.title,
                          note: task.note,
                          startTime: task.startTime,
                          endTime: task.endTime,
                          date: task.date,
                          remind: task.remind,
                          color: task.color,
                          isCompleted: task.isCompleted,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
