import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/widgets/container.dart';
import 'package:dedo/widgets/task_detail_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// A custom task tile widget showing task summary info:
/// - Title with an eye icon button to open detailed view.
/// - Time range and completion status chip.
/// - A single-line truncated note preview.
///
/// Uses a colored background and rounded corners matching the task's color.
class DTaskTile extends StatelessWidget {
  const DTaskTile({
    super.key,
    required this.title,
    required this.note,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.remind,
    required this.color,
    required this.isCompleted,
  });

  final String title, note;
  final String startTime, endTime, date;
  final int remind;
  final int color;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return DContainer(
      width: double.infinity,
      padding: EdgeInsets.all(DSizes.sm), // Uniform padding inside tile
      margin: EdgeInsets.only(bottom: DSizes.xs), // Spacing below tile
      borderRadius: BorderRadius.circular(DSizes.md), // Rounded corners
      backgroundColor: Color(color), // Background color from task data
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Title row with expandable text and "eye" icon button
          // to view detailed info in a modal bottom sheet.
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: DColors.black,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    shadows: [
                      Shadow(
                        offset: Offset(0.5, 0.5),
                        blurRadius: 1,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_red_eye,
                  size: 20,
                  color: DColors.black,
                ),
                onPressed: () {
                  // Show modal bottom sheet with detailed task info
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? DColors.light
                            : DColors.dark,
                    isScrollControlled: true,
                    builder:
                        (_) => TaskDetailBottomSheet(
                          title: title,
                          note: note,
                          startTime: startTime,
                          endTime: endTime,
                          date: date,
                          remind: remind,
                          isCompleted: isCompleted,
                        ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: DSizes.xs),

          // Row showing time range on the left and completion status chip on the right.
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 20, color: DColors.black),
              SizedBox(width: DSizes.sm),
              Text(
                "$startTime - $endTime",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: DColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Spacer(), // Pushes status chip to far right
              // Status chip with gradient background and shadow
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isCompleted
                            ? [
                              Color(0xFF4CAF50),
                              Color(0xFF81C784),
                            ] // Green gradient for completed
                            : [
                              Color(0xFFFF9800),
                              Color(0xFFFFB74D),
                            ], // Orange gradient for pending
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.pending,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCompleted ? "Completed" : "Pending",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: DSizes.xs),

          // Single-line preview of the note with ellipsis overflow.
          Text(
            note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: DColors.black,
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
