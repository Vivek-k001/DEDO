import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/bloc/theme/theme_bloc.dart';
import 'package:dedo/models/task_model.dart';
import 'package:dedo/screens/add_task.dart';
import 'package:dedo/services/notification_service.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/constants/text.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/appbar.dart';
import 'package:dedo/widgets/button.dart';
import 'package:dedo/widgets/task_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now();

    return Scaffold(
      appBar: DAppBar(
        title: Text(
          DTexts.appName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),

        actions: [
          /// Theme Switcher
          BlocBuilder<ThemeBloc, ThemeMode>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state == ThemeMode.dark
                      ? Icons.nightlight_round
                      : Icons.wb_sunny,
                  color: state == ThemeMode.dark ? DColors.light : DColors.dark,
                ),
                onPressed: () async {
                  context.read<ThemeBloc>().add(
                    ThemeChangedEvent(state == ThemeMode.dark ? false : true),
                  );
                  final allowed =
                      await NotificationService()
                          .requestNotificationPermission();
                  if (allowed) {
                    NotificationService().showNotification(
                      id: 1,
                      title: "Theme Changed",
                      body:
                          state == ThemeMode.dark
                              ? "Switched to light mode"
                              : "Switched to dark mode",
                    );
                  } else {
                    if (kDebugMode) {
                      print("Notification permission denied");
                    }
                    await NotificationService().requestNotificationPermission();
                  }
                },
              );
            },
          ),

          /// Profile Icon
          IconButton(
            icon: Icon(
              Icons.person,
              color:
                  DHelperFunctions.isDarkMode(context)
                      ? DColors.light
                      : DColors.dark,
            ),
            onPressed: () {},
          ),
        ],
      ),

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

      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DSizes.md,
          vertical: DSizes.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: DSizes.sm),
              child: Text(
                DHelperFunctions.formatDate(DateTime.now()),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),

            const SizedBox(height: DSizes.spaceBtwItems),

            Container(
              padding: const EdgeInsets.all(DSizes.sm),
              decoration: BoxDecoration(
                color:
                    DHelperFunctions.isDarkMode(context)
                        ? DColors.darkerGrey
                        : DColors.darkGrey,
                borderRadius: BorderRadius.circular(DSizes.sm),
              ),
              child: DatePicker(
                DateTime.now(),
                height: 100,
                width: 80,
                initialSelectedDate: DateTime.now(),
                selectionColor: DColors.primary,
                selectedTextColor:
                    DHelperFunctions.isDarkMode(context)
                        ? DColors.light
                        : DColors.dark,
                dateTextStyle: Theme.of(context).textTheme.headlineSmall!,
                dayTextStyle: Theme.of(context).textTheme.bodyMedium!,
                monthTextStyle: Theme.of(context).textTheme.bodySmall!,
                onDateChange: (date) {
                  selectedDate = date;
                  if (kDebugMode) {
                    print(selectedDate);
                  }
                },
              ),
            ),

            const SizedBox(height: DSizes.spaceBtwItems),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DSizes.defaultSpace,
              ),
              child: Text(
                "Tasks",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),

            const SizedBox(height: DSizes.spaceBtwItems),

            /// Task List
            Expanded(
              child: BlocConsumer<TaskBloc, TaskState>(
                listener: (context, state) {
                  if (state is TaskError) {
                    DHelperFunctions.showSnackBar(
                      title: "Error",
                      message: "Error ${state.message}",
                      icon: Icons.error,
                      context: context,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TaskLoaded) {
                    if (state.tasks.isEmpty) {
                      return const Center(child: Text("No tasks available"));
                    }
                    return ListView.builder(
                      itemCount: state.tasks.length,
                      itemBuilder: (context, index) {
                        final task = state.tasks[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          child: SlideAnimation(
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _taskOptionsBottomSheet(
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
                                    colorIndex: task.color,
                                    isCompleted:
                                        task.isCompleted == 1 ? true : false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _taskOptionsBottomSheet(
    BuildContext context,
    TaskModel task,
    bool isCompleted,
  ) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(DSizes.md),
          height: DHelperFunctions.screenHeight(context) * 0.32,
          decoration: BoxDecoration(
            color:
                DHelperFunctions.isDarkMode(context)
                    ? DColors.darkerGrey
                    : DColors.lightGrey,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(DSizes.sm),
              topRight: Radius.circular(DSizes.sm),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: DSizes.spaceBtwSections),

              DButton(
                onTap: () {
                  context.read<TaskBloc>().add(
                    UpdateSingleField(
                      task.id!,
                      "isCompleted",
                      task.isCompleted == 0 ? 1 : 0,
                    ),
                  );
                  DHelperFunctions.showSnackBar(
                    title: "Success",
                    message: "Task updated successfully!",
                    icon: Icons.check_circle,
                    bgColor: Colors.green,
                    context: context,
                  );
                  Navigator.pop(context);
                },
                btnTitle: isCompleted ? "Mark as Pending" : "Mark as Completed",
                width: double.infinity,
                height: 55,
                btnColor: Colors.blue,
                showBorder: true,
              ),

              SizedBox(height: DSizes.spaceBtwItems),

              DButton(
                onTap: () {
                  context.read<TaskBloc>().add(DeleteTask(task.id!));
                  DHelperFunctions.showSnackBar(
                    title: "Success",
                    message: "Task deleted successfully!",
                    icon: Icons.check_circle,
                    context: context,
                    bgColor: Colors.green,
                  );
                  Navigator.pop(context);
                },
                btnTitle: "Delete Task",
                width: double.infinity,
                height: 55,
                btnColor: Colors.red,
                showBorder: true,
              ),

              SizedBox(height: DSizes.spaceBtwItems),

              DButton(
                onTap: () => Navigator.pop(context),
                btnTitle: "Close",
                width: double.infinity,
                height: 55,
                btnColor: Colors.white70,
                showBorder: true,
              ),

              SizedBox(height: DSizes.spaceBtwSections),
            ],
          ),
        );
      },
    );
  }
}
