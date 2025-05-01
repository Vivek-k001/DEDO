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

  final DateTime selectedDate;
  final TaskFilter currentFilter;
  final String searchQuery;
  final SortOption currentSort;

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskError) {
          DHelperFunctions.showSnackBar(
            title: "Error",
            message: "Error ${state.message}",
            icon: Icons.error,
            context: context,
            bgColor: Colors.red,
          );
        }
      },
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TaskLoaded) {
          // Filter by date
          final dateString = DateFormat('dd/MM/yyyy').format(selectedDate);
          List<TaskModel> dateFilteredTasks =
              state.tasks.where((task) {
                return task.date == dateString;
              }).toList();

          // Assign dateFilteredTasks to filteredTasks
          List<TaskModel> filteredTasks = dateFilteredTasks;

          // Filter by task status
          if (currentFilter == TaskFilter.pending) {
            filteredTasks =
                dateFilteredTasks
                    .where((task) => task.isCompleted == 0)
                    .toList();
          } else if (currentFilter == TaskFilter.completed) {
            filteredTasks =
                dateFilteredTasks
                    .where((task) => task.isCompleted == 1)
                    .toList();
          }

          // Filter by search query (title & note)
          if (searchQuery.isNotEmpty) {
            filteredTasks =
                filteredTasks
                    .where(
                      (task) =>
                          task.title.toLowerCase().contains(
                            searchQuery.toLowerCase(),
                          ) ||
                          task.note.toLowerCase().contains(
                            searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();
          }

          // Filter by sort option
          switch (currentSort) {
            case SortOption.newest:
              filteredTasks.sort((a, b) => a.startTime.compareTo(b.startTime));
              break;
            case SortOption.oldest:
              filteredTasks.sort((a, b) => b.startTime.compareTo(a.startTime));
              break;
            case SortOption.titleAsc:
              filteredTasks.sort((a, b) => a.title.compareTo(b.title));
              break;
            case SortOption.titleDesc:
              filteredTasks.sort((a, b) => b.title.compareTo(a.title));
              break;
          }

          // Empty Task view
          if (filteredTasks.isEmpty) {
            return Center(
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
                    "No tasks available",
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
                        taskOptionsBottomSheet(
                          context,
                          task,
                          task.isCompleted == 1 ? true : false,
                        );
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
                        isCompleted: task.isCompleted == 1 ? true : false,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
