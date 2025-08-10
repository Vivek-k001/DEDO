import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/widgets/container.dart';
import 'package:flutter/material.dart';

class DAnalytics extends StatelessWidget {
  const DAnalytics({
    super.key,
    required this.completed,
    required this.total,
    required this.weeklyStats,
  });

  // Number of tasks completed
  final int completed;

  // Total number of tasks
  final int total;

  // List of weekly statistics (e.g., task completions per day)
  final List<double> weeklyStats;

  @override
  Widget build(BuildContext context) {
    // Calculate completion rate percentage, avoid division by zero
    final completionRate = total > 0 ? (completed / total) * 100 : 0.0;

    // Find index of the best day (day with highest value in weeklyStats)
    final bestDay =
        weeklyStats.isNotEmpty
            ? weeklyStats.indexOf(weeklyStats.reduce((a, b) => a > b ? a : b))
            : -1;

    // Day names for display
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return DContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title "Analytics"
          Text(
            "Analytics",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: DSizes.md),

          // Row containing two analytic items: Completion Rate and Best Day
          Row(
            children: [
              Expanded(
                child: _buildAnalyticItem(
                  'Completion Rate',
                  '${completionRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  // Color based on completion rate thresholds
                  completionRate > 70
                      ? Colors.green
                      : completionRate > 40
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
              const SizedBox(width: DSizes.md),

              Expanded(
                child: _buildAnalyticItem(
                  'Best Day',
                  // Show abbreviated day name or 'N/A' if none
                  bestDay >= 0 ? dayNames[bestDay].substring(0, 3) : 'N/A',
                  Icons.star,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build each analytic info container
  Widget _buildAnalyticItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return DContainer(
      padding: const EdgeInsets.all(DSizes.sm),
      backgroundColor: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(DSizes.sm),
      child: Column(
        children: [
          // Icon representing the analytic metric
          Icon(icon, color: color, size: 20),
          const SizedBox(height: DSizes.xs),

          // Numeric or text value with strong color emphasis
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: DSizes.xs),

          // Title describing the analytic metric
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
