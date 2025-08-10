import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:flutter/material.dart';

class TaskHeader extends StatelessWidget {
  const TaskHeader({super.key, required this.isEditing});

  // Flag to determine if the form is in edit mode or create mode
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Column(
      // Center align children horizontally
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Row containing icon and title text side-by-side
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Task icon with fixed size and color
            Icon(Icons.task_alt, size: 50, color: DColors.darkerGrey),

            // Horizontal spacing between icon and text
            SizedBox(height: DSizes.spaceBtwSections),

            // Title text changes based on whether editing or creating new task
            Text(
              isEditing ? 'Edit Task' : 'Create New Task',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        // Vertical space after the row
        const SizedBox(height: DSizes.sm),

        // Subtitle text explaining what to do next, also changes based on editing flag
        Text(
          isEditing
              ? 'Update the task details below'
              : "Fill in the details below to add a new task to your list",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color:
                DHelperFunctions.isDarkMode(context)
                    ? DColors.light.withValues(
                      alpha: 0.7,
                    ) // light color with transparency in dark mode
                    : DColors.dark.withValues(
                      alpha: 0.7,
                    ), // dark color with transparency in light mode
          ),
          textAlign: TextAlign.center,
        ),

        // Additional vertical spacing after subtitle
        const SizedBox(height: DSizes.sm),
      ],
    );
  }
}
