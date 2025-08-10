import 'package:dedo/models/category_model.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/widgets/container.dart';
import 'package:flutter/material.dart';

class DCategoryContainer extends StatelessWidget {
  // The category to display
  final CategoryModel category;

  // Total number of tasks in this category
  final int taskCount;

  // Number of completed tasks in this category
  final int completedTasks;

  // Progress value (0.0 to 1.0) for the progress bar
  final double progress;

  // Optional tap callback
  final VoidCallback? onTap;

  const DCategoryContainer({
    super.key,
    required this.category,
    required this.taskCount,
    required this.progress,
    required this.completedTasks,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Invoke onTap callback when container is tapped
      onTap: onTap,
      child: DContainer(
        width: 150,
        margin: const EdgeInsets.only(left: DSizes.xs, right: DSizes.sm),
        padding: const EdgeInsets.all(DSizes.sm),
        backgroundColor: Color(category.color),
        boxShadow: [
          BoxShadow(
            // Shadow color with 10% opacity black
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display category name
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: DSizes.xs),

            // Display total task count
            Text(
              '$taskCount Tasks',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),

            const SizedBox(height: DSizes.xs),

            // Progress bar and completed tasks status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: progress, // progress value between 0 and 1
                  backgroundColor: Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: DSizes.xs),
                // Text showing how many tasks completed out of total
                Text(
                  '$completedTasks of $taskCount completed',
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
