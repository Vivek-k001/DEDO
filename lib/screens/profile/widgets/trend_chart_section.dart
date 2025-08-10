import 'package:dedo/screens/profile/widgets/todo_trend_chart.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/widgets/container.dart';
import 'package:flutter/material.dart';

class DTrendChartSection extends StatelessWidget {
  // Constructor with required weeklyStats parameter
  const DTrendChartSection({super.key, required this.weeklyStats});

  // List holding task counts for each day of the week
  final List<double> weeklyStats;

  @override
  Widget build(BuildContext context) {
    // Calculate total tasks completed in the entire week by summing the list
    final totalWeeklyTasks = weeklyStats.fold(0.0, (sum, count) => sum + count);
    // Calculate average tasks completed daily (total divided by 7 days)
    final averageDaily = totalWeeklyTasks / 7;

    return DContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row for title and total tasks badge aligned horizontally
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Section title text with medium style and bold weight
              Text(
                "Weekly Progress at a Glance",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              // Small container showing total weekly tasks count as a badge
              DContainer(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                child: Text(
                  '${totalWeeklyTasks.toInt()} this week',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSizes.sm),

          // Container displaying daily average tasks text
          Center(
            child: DContainer(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              child: Text(
                'Daily Average: ${averageDaily.toStringAsFixed(1)} tasks',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: DSizes.md),

          // The actual line chart widget showing weekly task trend
          DTodoTrendChart(weeklyData: weeklyStats),
        ],
      ),
    );
  }
}
