import 'package:dedo/bloc/category/category_bloc.dart';
import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/models/category_model.dart';
import 'package:dedo/screens/category/category_detail.dart';
import 'package:dedo/screens/category/widgets/category_item.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Section to display all categories in a list
/// This section handles loading, error states,
/// and deletion of categories with associated tasks check.
class DAllCategoryListSection extends StatelessWidget {
  const DAllCategoryListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return Expanded(
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          // Show loading indicator while categories load
          if (state is CategoryLoading) {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // Show error UI on error state
          if (state is CategoryError) {
            return SizedBox(
              height: 100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(height: 8),
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

          // Extract categories list from loaded or success states
          List<CategoryModel> categories = [];
          if (state is CategoryLoaded) {
            categories = state.categories;
          } else if (state is CategorySuccess) {
            categories = state.categories;
          }

          // Show placeholder if no categories exist
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 40,
                    color:
                        isDark
                            ? DColors.grey
                            : DColors.darkGrey.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: DSizes.sm),
                  Text(
                    'No categories found',
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

          // ListView to display all categories
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  DHelperFunctions.navigateToScreen(
                    context,
                    CategoryDetailScreen(category: category),
                  );
                },
                child: CategoryItem(
                  category: category,
                  onDelete: () {
                    // Check if any task exists for this category before deleting
                    final taskState = context.read<TaskBloc>().state;

                    if (taskState is TaskDataLoaded) {
                      final hasTasks = taskState.tasks.any(
                        (task) => task.categoryId == category.id,
                      );

                      // If tasks exist, prevent deletion and show error
                      if (hasTasks) {
                        DHelperFunctions.showSnackBar(
                          title: "Cannot Delete",
                          message: "Category has associated tasks",
                          icon: Icons.error,
                          context: context,
                          bgColor: Colors.red,
                        );
                        return;
                      }
                    }

                    // If no tasks linked, delete category
                    context.read<CategoryBloc>().add(
                      DeleteCategory(category.id),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
