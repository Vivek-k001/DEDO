import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/models/task_model.dart';
import 'package:dedo/screens/home/widgets/task_bottom_sheet.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/enum.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

class DTaskList extends StatelessWidget {
  const DTaskList({
    super.key,
    required this.selectedDate,
    required this.currentFilter,
    required this.searchQuery,
    required this.currentSort,
  });

  final DateTime selectedDate; // Currently selected date for filtering tasks
  final TaskFilter
  currentFilter; // Current filter for task status (all, pending, completed)
  final String searchQuery; // Current search string for filtering tasks by text
  final SortOption currentSort; // Current sort option for task list ordering

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        // Show loading spinner while tasks are loading
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error message if tasks failed to load
        if (state is TaskError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: DSizes.md),
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

        List<TaskModel> tasks = [];
        if (state is TaskDataLoaded) {
          tasks = state.tasks;
        } else if (state is TaskSuccess) {
          tasks = state.tasks;
        }

        // Filter and sort tasks based on current filter/sort/search
        final filteredTasks = filterAndSortTasks(tasks);

        // If no tasks after filtering, show empty state UI
        if (filteredTasks.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: DSizes.md),
            child: Center(
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
            ),
          );
        }

        // Display filtered and sorted task list with animation
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
        );
      },
    );
  }

  // Function to filter and sort tasks based on date, filter, search, and sort options
  List<TaskModel> filterAndSortTasks(List<TaskModel> tasks) {
    // Format selectedDate to string to compare with task dates
    final dateString = DateFormat('dd/MM/yyyy').format(selectedDate);

    // Filter tasks by selected date
    var filteredTasks = tasks.where((task) => task.date == dateString).toList();

    // Filter tasks based on completion status if filter applied
    if (currentFilter == TaskFilter.pending) {
      filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
    } else if (currentFilter == TaskFilter.completed) {
      filteredTasks = filteredTasks.where((task) => task.isCompleted).toList();
    }

    // Filter tasks by search query if not empty (search in title or note)
    if (searchQuery.isNotEmpty) {
      filteredTasks =
          filteredTasks
              .where(
                (task) =>
                    task.title.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    task.note.toLowerCase().contains(searchQuery.toLowerCase()),
              )
              .toList();
    }

    // Sort filtered tasks based on currentSort option
    switch (currentSort) {
      case SortOption.newest:
        filteredTasks.sort((a, b) => b.startTime.compareTo(a.startTime));
        break;
      case SortOption.oldest:
        filteredTasks.sort((a, b) => a.startTime.compareTo(b.startTime));
        break;
      case SortOption.titleAsc:
        filteredTasks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.titleDesc:
        filteredTasks.sort((a, b) => b.title.compareTo(a.title));
        break;
    }

    return filteredTasks;
  }
}
