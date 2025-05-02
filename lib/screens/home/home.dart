import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:dedo/bloc/category/category_bloc.dart';
import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/screens/home/widgets/categoy_chip.dart';
import 'package:dedo/screens/home/widgets/home_appbar.dart';
import 'package:dedo/screens/home/widgets/task_list.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/enum.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/container.dart';
import 'package:dedo/widgets/filter_chip.dart';
import 'package:dedo/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();

  TaskFilter currentFilter = TaskFilter.all;
  SortOption currentSort = SortOption.newest;

  String searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    context.read<TaskBloc>().add(LoadTasks());
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DHomeAppbar(),

      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskSuccess) {
            DHelperFunctions.showSnackBar(
              title: "Success",
              message: state.message,
              icon: Icons.check_circle,
              context: context,
              bgColor: Colors.green,
            );
          } else if (state is TaskError) {
            DHelperFunctions.showSnackBar(
              title: "Error",
              message: state.message,
              icon: Icons.error,
              context: context,
              bgColor: Colors.red,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Search bar
              DTextFormField(
                controller: _searchController,
                hintText: "Search tasks...",
                prefixIcon: Icons.search,
                title: "",
                suffixIcon: Icons.clear,
                onIconPressed: () {
                  _searchController.clear();
                  setState(() => searchQuery = '');
                },
                onChanged: (value) => setState(() => searchQuery = value),
              ),

              /// Date Timeline
              DContainer(
                child: DatePicker(
                  DateTime.now(),
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
              ),

              const SizedBox(height: DSizes.sm + DSizes.xs),

              /// Category Row
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CategoryLoaded ||
                      state is CategorySuccess) {
                    final categories =
                        (state is CategoryLoaded)
                            ? state.categories
                            : (state as CategorySuccess).categories;

                    if (categories.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(DSizes.sm),
                        child: const Center(child: Text('No categories Found')),
                      );
                    }

                    return DContainer(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];

                          return DCategoryChip(
                            category: category,
                            taskCount: 2,
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

              Row(
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
                                value: SortOption.newest,
                                child: Text("Newest First"),
                              ),
                              const PopupMenuItem(
                                value: SortOption.oldest,
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

              const SizedBox(height: DSizes.sm),

              /// Task status chip
              SingleChildScrollView(
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

              const SizedBox(height: DSizes.sm),

              /// Task List
              Expanded(
                child: DTaskList(
                  selectedDate: _selectedDate,
                  currentFilter: currentFilter,
                  searchQuery: searchQuery,
                  currentSort: currentSort,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for filter chip
  Widget _buildFilterChip(String label, TaskFilter filter) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return DFilterChip(
      label: label,
      isSelected: currentFilter == filter,
      onSelected: (selected) {
        setState(() => currentFilter = filter);
      },
      backgroundColor: isDark ? DColors.dark : DColors.light,
      selectedColor: DColors.primary,
      selectedTextColor: DColors.black,
    );
  }
}
