import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:dedo/bloc/task/task_bloc.dart';
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
            /// Search bar
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

            const SizedBox(height: DSizes.sm),

            /// Date Timeline
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
                dateTextStyle: Theme.of(context).textTheme.titleMedium!,
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

            const SizedBox(height: DSizes.sm),

            /// Category Row
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
                                color: Colors.grey.withValues(alpha: 0.2),
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

            const SizedBox(height: DSizes.sm),

            /// Task Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Task text
                Text("Tasks", style: Theme.of(context).textTheme.headlineSmall),

                // Sort Menu
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
                              child: Text("Newest"),
                            ),
                            const PopupMenuItem(
                              value: SortOption.oldest,
                              child: Text("Oldest"),
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
    );
  }

  // Widget for filter chip
  Widget _buildFilterChip(String label, TaskFilter filter) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return DFilterChip(
      label: label,
      isSelected: currentFilter == filter,
      onSelected: (selected) {
        setState(() {
          currentFilter = filter;
        });
      },
      backgroundColor: isDark ? DColors.darkerGrey : DColors.lightContainer,
      selectedColor: DColors.primary.withValues(alpha: 0.2),
      checkmarkColor: isDark ? DColors.primary : DColors.darkerGrey,
    );
  }
}
