import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/models/category_model.dart';
import 'package:dedo/screens/home/widgets/task_bottom_sheet.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/container.dart';
import 'package:dedo/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryListView extends StatelessWidget {
  final CategoryModel category;

  const CategoryListView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${category.name} Tasks'),
        backgroundColor: Color(category.color),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            final tasks = state.tasks;

            // Filter by category ID
            final filteredTasks =
                tasks.where((task) => task.categoryId == category.id).toList();

            if (filteredTasks.isEmpty) {
              return const Center(child: Text("No tasks in this category"));
            }

            return ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return GestureDetector(
                  onTap: () {
                    taskOptionsBottomSheet(context, task);
                  },
                  child: DContainer(
                    margin: const EdgeInsets.all(DSizes.sm),
                    padding: const EdgeInsets.all(DSizes.sm),
                    backgroundColor:
                        isDark ? DColors.darkerGrey : DColors.lightContainer,
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
                );
              },
            );
          } else {
            return const Center(child: Text('No Tasks found'));
          }
        },
      ),
    );
  }
}
