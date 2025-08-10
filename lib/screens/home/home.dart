import 'dart:async';
import 'package:dedo/bloc/category/category_bloc.dart';
import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/screens/home/widgets/category_list_section.dart';
import 'package:dedo/screens/home/widgets/date_timeline.dart';
import 'package:dedo/screens/home/widgets/home_appbar.dart';
import 'package:dedo/screens/home/widgets/task_list.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/enum.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/filter_chip.dart';
import 'package:dedo/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// HomePage is the main screen displaying tasks and categories.
/// It manages filtering, sorting, and search functionalities,
/// while interacting with TaskBloc and CategoryBloc for state management.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Tracks the currently selected date to filter tasks
  DateTime _selectedDate = DateTime.now();

  // Timer used to debounce date changes to avoid rapid reloading
  Timer? _debounceTimer;
  final Duration _debounceDelay = const Duration(milliseconds: 500);

  // Current filter applied to task list (e.g., all, pending, completed)
  TaskFilter currentFilter = TaskFilter.all;

  // Current sorting option applied to the task list
  SortOption currentSort = SortOption.newest;

  // Current text entered in the search bar
  String searchQuery = '';

  // Controller for the search input to manage text programmatically
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initial loading of tasks and categories when the screen is created
    context.read<TaskBloc>().add(LoadTasks());
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  void dispose() {
    // Properly cancel the debounce timer if active and dispose text controller
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Handles date changes from the timeline widget.
  /// Uses debounce to delay action and reduce unnecessary state rebuilds and data fetching.
  void _handleDateChange(DateTime date) {
    // Cancel previous debounce timer to reset delay
    _debounceTimer?.cancel();

    // Set a new debounce timer to update selected date and reload tasks after delay
    _debounceTimer = Timer(_debounceDelay, () {
      setState(() => _selectedDate = date);
      // Notify TaskBloc to reload tasks for the new date filter
      context.read<TaskBloc>().add(LoadTasks());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DHomeAppbar(),

      // Listen to TaskBloc state changes to show feedback messages (success or error)
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskSuccess) {
            // Show green success snackbar and refresh task list
            DHelperFunctions.showSnackBar(
              title: "Success",
              message: state.message,
              icon: Icons.check_circle,
              context: context,
              bgColor: Colors.green,
            );
            context.read<TaskBloc>().add(LoadTasks());
          }

          if (state is TaskError) {
            // Show red error snackbar with relevant message
            DHelperFunctions.showSnackBar(
              title: "Error",
              message: state.message,
              icon: Icons.error,
              context: context,
              bgColor: Colors.red,
            );
          }
        },

        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: DSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DSizes.sm),

              // Search input for filtering tasks by text query.
              DTextFormField(
                controller: _searchController,
                hintText: "Search tasks...",
                prefixIcon: Icons.search,
                showShadow: true,
                title: "",
                suffixIcon:
                    _searchController.text.isNotEmpty ? Icons.clear : null,
                onIconPressed: () {
                  _searchController.clear();
                  setState(() => searchQuery = '');
                },
                onChanged: (value) => setState(() => searchQuery = value),
              ),

<<<<<<< HEAD
              // Horizontal date selector for filtering tasks by selected date
              DDateTimeline(onDateChange: _handleDateChange),
              const SizedBox(height: DSizes.md),

              // Section header for categories
              Text(
                "Categories",
                style: Theme.of(context).textTheme.headlineSmall,
=======
              /// Date Timeline
              DContainer(
                child: DatePicker(
                  DateTime.now().subtract(Duration(days: 1000)),
                  height: 90,
                  width: 60,
                  initialSelectedDate: _selectedDate,
                  selectionColor: DColors.primary,
                  selectedTextColor: DColors.dark,
                  dateTextStyle: Theme.of(context).textTheme.titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                  dayTextStyle: Theme.of(context).textTheme.bodySmall!,
                  monthTextStyle: Theme.of(context).textTheme.bodyMedium!,
                  onDateChange: (date) {
                    setState(() => _selectedDate = date);
                    context.read<TaskBloc>().add(LoadTasks());
                  },
                ),
>>>>>>> 65b05861cc69881293ed88eeeb876d472818ce22
              ),
              const SizedBox(height: DSizes.sm),

<<<<<<< HEAD
              // Category list section displaying all categories with task counts
              DCategoryListSection(),
              const SizedBox(height: DSizes.sm),
=======
              const SizedBox(height: DSizes.sm + DSizes.xs),

              /// Category Row
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CategoryLoaded ||
                      state is CategorySuccess) {
                    final categories =
                        state is CategoryLoaded
                            ? state.categories
                            : (state as CategorySuccess).categories;

                    if (categories.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(DSizes.sm),
                        child: Center(child: Text('No categories found')),
                      );
                    }

                    return SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];

                          final totalTasks = category.toMap().length;

                          int completedTasks = 4;
                          final double progress =
                              totalTasks == 0 ? 0 : completedTasks / totalTasks;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: SizedBox(
                              width: 150, // Ensure width
                              child: DCategoryChip(
                                category: category,
                                taskCount: totalTasks,
                                progress: progress,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => CategoryListView(
                                            category: category,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else if (state is CategoryError) {
                    return Center(child: Text(state.message));
                  } else {
                    return const Center(child: Text('No categories found'));
                  }
                },
              ),

              const SizedBox(height: DSizes.sm + DSizes.xs),
>>>>>>> 65b05861cc69881293ed88eeeb876d472818ce22

              // Header row for task list with sorting popup menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tasks",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  // Popup menu for selecting sorting options
                  PopupMenuButton<SortOption>(
                    tooltip: "Sort Tasks",
                    icon: const Icon(Icons.sort),
                    onSelected: (SortOption sort) {
                      // Update sort state and refresh list order
                      setState(() => currentSort = sort);
                    },
                    itemBuilder:
                        (context) => const [
                          PopupMenuItem(
                            value: SortOption.newest,
                            child: Text("Newest First"),
                          ),
                          PopupMenuItem(
                            value: SortOption.oldest,
                            child: Text("Oldest First"),
                          ),
                          PopupMenuItem(
                            value: SortOption.titleAsc,
                            child: Text("Title (A-Z)"),
                          ),
                          PopupMenuItem(
                            value: SortOption.titleDesc,
                            child: Text("Title (Z-A)"),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: DSizes.sm),

              // Filter chips row for quick task filtering by status
              Row(
                children: [
                  _buildFilterChip("All", TaskFilter.all),
                  const SizedBox(width: DSizes.xs),
                  _buildFilterChip("Pending", TaskFilter.pending),
                  const SizedBox(width: DSizes.xs),
                  _buildFilterChip("Completed", TaskFilter.completed),
                ],
              ),
              const SizedBox(height: DSizes.sm),

              // Main task list widget with all active filters and sorting applied
              DTaskList(
                selectedDate: _selectedDate,
                currentFilter: currentFilter,
                searchQuery: searchQuery,
                currentSort: currentSort,
              ),
              const SizedBox(height: DSizes.md),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a filter chip widget used for toggling task filters.
  /// Applies current selection style and updates state on tap.
  Widget _buildFilterChip(String label, TaskFilter filter) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return DFilterChip(
      label: label,
      isSelected: currentFilter == filter,
      onSelected: (selected) {
        // Update current filter and refresh task list accordingly
        setState(() => currentFilter = filter);
      },
      backgroundColor: isDark ? DColors.dark : DColors.light,
      selectedColor: DColors.primary,
      selectedTextColor: DColors.black,
    );
  }
}
