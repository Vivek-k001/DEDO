import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/bloc/theme/theme_bloc.dart';
import 'package:dedo/screens/add_task.dart';
import 'package:dedo/services/notification_service.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/constants/text.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/appbar.dart';
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
          style: Theme.of(context).textTheme.headlineSmall,
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

            Text("Tasks", style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: DSizes.spaceBtwItems),

            /// Task List
            Expanded(
              child: BlocConsumer<TaskBloc, TaskState>(
                listener: (context, state) {
                  if (state is TaskError) {
                    DHelperFunctions.showSnackBar(
                      message: "Error ${state.message}",
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
                                  onTap: () {},
                                  child: DTaskTile(
                                    title: task.title,
                                    note: task.note,
                                    startTime: task.startTime,
                                    endTime: task.endTime,
                                    date: task.date,
                                    repeat: task.repeat,
                                    remind: task.remind,
                                    color: task.color,
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
                    return const Center(child: Text("Tasks not found"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
