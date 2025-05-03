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
  DTaskList({
    super.key,
    required this.selectedDate,
    required this.currentFilter,
    required this.searchQuery,
    required this.currentSort,
  });

  final DateTime selectedDate;
  final TaskFilter currentFilter;
  final String searchQuery;
  final SortOption currentSort;

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TaskLoaded) {
          final tasks = state.tasks;

          final filteredTasks = filterAndSortTasks(tasks);

          // Empty Task view
          if (filteredTasks.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(DSizes.sm),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 60,
                      color:
                          isDark
                              ? DColors.grey
                              : DColors.darkGrey.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: DSizes.spaceBtwItems),
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

          // Task list
          return ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];

              return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: GestureDetector(
                      onTap: () {
                        taskOptionsBottomSheet(context, task);
                      },
                      child: DTaskTile(
                        title: task.title,
                        note: task.note,
                        startTime: task.startTime,
                        endTime: task.endTime,
                        date: task.date,
                        repeat: task.repeat,
                        remind: task.remind,
                        colorIndex: task.colorIndex,
                        isCompleted: task.isCompleted,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No Tasks found'));
        }
      },
    );
  }

  List<TaskModel> filterAndSortTasks(List<TaskModel> tasks) {
    // Date filtering
    final dateString = DateFormat('dd/MM/yyyy').format(selectedDate);

    var filteredTasks = tasks.where((task) => task.date == dateString).toList();

    // Status filtering
    if (currentFilter == TaskFilter.pending) {
      filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
    } else if (currentFilter == TaskFilter.completed) {
      filteredTasks = filteredTasks.where((task) => task.isCompleted).toList();
    }

    // Search filtering
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

    // Sorting
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
