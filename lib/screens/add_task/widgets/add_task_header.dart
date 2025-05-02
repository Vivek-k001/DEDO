import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:flutter/material.dart';

class AddTaskHeader extends StatelessWidget {
  const AddTaskHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 50, color: DColors.darkerGrey),
            const SizedBox(height: DSizes.spaceBtwItems),
            Text(
              "Create New Task",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: DSizes.sm),
        Text(
          "Fill in the details below to add a new task to your list",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color:
                DHelperFunctions.isDarkMode(context)
                    ? DColors.light.withValues(alpha: 0.7)
                    : DColors.dark.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DSizes.spaceBtwItems),
      ],
    );
  }
}
