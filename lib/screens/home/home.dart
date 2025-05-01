import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/models/task_model.dart';
import 'package:dedo/screens/home/widgets/home_appbar.dart';
import 'package:dedo/screens/home/widgets/task_bottom_sheet.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/enum.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/task_tile.dart';
import 'package:dedo/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();

  TaskFilter currentFilter = TaskFilter.all;
  SortOption currentSort = SortOption.dateDesc;

  String searchQuery = '';
  final _searchController = TextEditingController();

  final List<String> categories = [
    "Health",
    "Payments",
    "Work",
    "Study",
    "Studyf",
    "Studys",
    "Studyr",
  ];
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: DHomeAppbar(),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: isDark ? DColors.black : DColors.lightContainer,
                borderRadius: BorderRadius.circular(DSizes.md),
                border: Border.all(
                  color: isDark ? DColors.black : DColors.lightGrey,
                ),
              ),
              child: DTextFormField(
                hintText: "Search tasks...",
                prefixIcon: Icons.search,
                title: "",
                suffixWidget:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              searchQuery = '';
                            });
                          },
                        )
                        : null,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),

            const SizedBox(height: DSizes.spaceBtwItems),

            Container(
              padding: const EdgeInsets.symmetric(vertical: DSizes.xs),
              decoration: BoxDecoration(
                color: isDark ? DColors.black : DColors.lightContainer,
                borderRadius: BorderRadius.circular(DSizes.sm),
              ),
              child: DatePicker(
                DateTime.now(),
                height: 90,
                width: 60,
                initialSelectedDate: _selectedDate,
                selectionColor: DColors.primary,
                selectedTextColor: isDark ? DColors.light : DColors.dark,
                dateTextStyle: Theme.of(context).textTheme.headlineSmall!,
                dayTextStyle: Theme.of(context).textTheme.bodyMedium!,
                monthTextStyle: Theme.of(context).textTheme.bodySmall!,
                onDateChange: (date) {
                  setState(() {
                    _selectedDate = date;
                  });

                  context.read<TaskBloc>().add(LoadTasks());
                },
              ),
            ),

            const SizedBox(height: DSizes.spaceBtwItems),
            Container(
              height: 90,
              padding: const EdgeInsets.symmetric(vertical: DSizes.xs),
              decoration: BoxDecoration(
                color: isDark ? DColors.black : DColors.lightContainer,
                borderRadius: BorderRadius.circular(DSizes.sm),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      categories.map((category) {
                        return Container(
                          margin: EdgeInsets.only(right: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "2 todos",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                category,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            const SizedBox(height: DSizes.spaceBtwItems),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: DSizes.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tasks",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  Row(
                    children: [
                      PopupMenuButton<SortOption>(
                        tooltip: "Sort Tasks",
                        icon: const Icon(Icons.sort),
                        onSelected: (SortOption sort) {
                          setState(() {
                            currentSort = sort;
                          });
                        },
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: SortOption.dateDesc,
                                child: Text("Newest First"),
                              ),
                              const PopupMenuItem(
                                value: SortOption.dateAsc,
                                child: Text("Oldest First"),
                              ),
                              const PopupMenuItem(
                                value: SortOption.titleAsc,
                                child: Text("Title (A-Z)"),
                              ),
                              const PopupMenuItem(
                                value: SortOption.titleDesc,
                                child: Text("Title (Z-A)"),
                              ),
                            ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSizes.sm),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: DSizes.xs),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip("All", TaskFilter.all),
                    const SizedBox(width: DSizes.xs),
                    _buildFilterChip("Pending", TaskFilter.pending),
                    const SizedBox(width: DSizes.xs),
                    _buildFilterChip("Completed", TaskFilter.completed),
                  ],
                ),
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
                      bgColor: Colors.red,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TaskLoaded) {
                    List<TaskModel> dateFilteredTasks =
                        state.tasks.where((task) {
                          final dateString = DateFormat(
                            'dd/MM/yyyy',
                          ).format(_selectedDate);
                          return task.date == dateString;
                        }).toList();

                    List<TaskModel> filteredTasks = dateFilteredTasks;

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

                    switch (currentSort) {
                      case SortOption.dateAsc:
                        filteredTasks.sort((a, b) => a.date.compareTo(b.date));
                        break;
                      case SortOption.dateDesc:
                        filteredTasks.sort((a, b) => b.date.compareTo(a.date));
                        break;
                      case SortOption.titleAsc:
                        filteredTasks.sort(
                          (a, b) => a.title.compareTo(b.title),
                        );
                        break;
                      case SortOption.titleDesc:
                        filteredTasks.sort(
                          (a, b) => b.title.compareTo(a.title),
                        );
                        break;
                    }

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
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium!.copyWith(
                                color:
                                    isDark
                                        ? DColors.grey
                                        : DColors.darkGrey.withValues(
                                          alpha: 0.5,
                                        ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

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
                                  isCompleted:
                                      task.isCompleted == 1 ? true : false,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, TaskFilter filter) {
    return FilterChip(
      label: Text(label),
      selected: currentFilter == filter,
      onSelected: (selected) {
        setState(() {
          currentFilter = filter;
        });
      },
      backgroundColor:
          DHelperFunctions.isDarkMode(context)
              ? DColors.darkerGrey
              : DColors.lightContainer,
      selectedColor: DColors.primary.withValues(alpha: 0.2),
      checkmarkColor: DColors.primary,
    );
  }
}
