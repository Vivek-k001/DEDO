import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/widgets/stat_card.dart';
import 'package:flutter/material.dart';

class DStatisticsSection extends StatelessWidget {
  const DStatisticsSection({
    super.key,
    required this.completed,
    required this.pending,
    required this.streak,
    required this.total,
  });

  final int completed;
  final int pending;
  final int streak;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Stat card for Completed tasks
        Expanded(
          child: StatCard(
            title: 'Completed',
            value: completed,
            icon: Icons.check_circle,
            color: Colors.green,
            subtitle:
                total > 0
                    ? '${((completed / total) * 100).toStringAsFixed(1)}%'
                    : '0%', // Percentage of completed tasks
          ),
        ),
        const SizedBox(width: DSizes.sm),

        // Stat card for Pending tasks
        Expanded(
          child: StatCard(
            title: 'Pending',
            value: pending,
            icon: Icons.access_time,
            color: Colors.orange,
            subtitle:
                total > 0
                    ? '${((pending / total) * 100).toStringAsFixed(1)}%'
                    : '0%', // Percentage of pending tasks
          ),
        ),
        const SizedBox(width: DSizes.sm),

        // Stat card for current Streak
        Expanded(
          child: StatCard(
            title: 'Streak',
            value: streak,
            icon: Icons.local_fire_department,
            color:
                streak > 0
                    ? Colors.red
                    : Colors.grey, // Red if streak positive, grey otherwise
            subtitle: _getStreakMessage(
              streak,
            ), // Message based on streak value
          ),
        ),
      ],
    );
  }

  // Returns streak message based on the streak count
  String _getStreakMessage(int streak) {
    if (streak == 0) return 'Start today!';
    if (streak == 1) return 'Great start!';
    if (streak < 7) return 'Keep going!';
    if (streak < 30) return 'On fire! 🔥';
    return 'Legendary! 🏆';
  }
}
