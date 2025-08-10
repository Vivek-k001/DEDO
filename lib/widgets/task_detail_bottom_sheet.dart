import 'package:flutter/material.dart';

/// A bottom sheet widget that displays detailed information about a task.
/// Includes title, completion status, timing, date, reminder, and notes.
/// Designed as a stateless widget since it only displays passed-in data.
class TaskDetailBottomSheet extends StatelessWidget {
  final String title;
  final String note;
  final String startTime;
  final String endTime;
  final String date;
  final int remind;
  final bool isCompleted;

  const TaskDetailBottomSheet({
    super.key,
    required this.title,
    required this.note,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.remind,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    // Outer padding defines spacing inside the bottom sheet, ensuring content
    // does not touch screen edges and looks visually balanced.
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Shrink-wrap height to content.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Displays task title on the left, completion status icon on the right.
          // Using Theme's headlineSmall style with bold weight for prominence.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                // Green check_circle if completed; orange pending icon otherwise.
                isCompleted ? Icons.check_circle : Icons.pending,
                color: isCompleted ? Colors.green : Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Time info with a clock icon, shows start and end time.
          // BlueGrey color used to visually indicate secondary info.
          Row(
            children: [
              const Icon(Icons.access_time, size: 20, color: Colors.blueGrey),
              const SizedBox(width: 8),
              Text(
                "$startTime - $endTime",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date info with calendar icon.
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 20,
                color: Colors.blueGrey,
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Reminder info with notification icon and minutes before reminder.
          Row(
            children: [
              const Icon(
                Icons.notifications_active,
                size: 20,
                color: Colors.blueGrey,
              ),
              const SizedBox(width: 8),
              Text(
                "Reminds before: $remind min",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Note section header with medium title style and semi-bold weight.
          Text(
            "Note",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // The note content displayed with larger body text for readability.
          Text(note, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
