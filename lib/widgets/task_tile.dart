import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:flutter/material.dart';

class DTaskTile extends StatelessWidget {
  const DTaskTile({
    super.key,
    this.bgColor,
    required this.title,
    required this.note,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.repeat,
    required this.remind,
    required this.color,
    required this.isCompleted,
  });

  final Color? bgColor;
  final String title, note;
  final String startTime, endTime, date, repeat;
  final int remind;
  final int color;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final isDark = DHelperFunctions.isDarkMode(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DSizes.md),
      margin: EdgeInsets.only(bottom: DSizes.sm + DSizes.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSizes.md),
        color: bgColor ?? (isDark ? DColors.darkerGrey : DColors.lightGrey),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: DSizes.spaceBtwItems),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 18,
                    color: DColors.primary,
                  ),
                  SizedBox(width: DSizes.sm),
                  Text(
                    "$startTime - $endTime",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

              SizedBox(height: DSizes.sm + DSizes.xs),

              Text(
                note,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(width: DSizes.sm),
          Container(
            height: 60,
            width: 1,
            color: isDark ? DColors.light : DColors.dark,
          ),
          const SizedBox(width: DSizes.sm),
          RotatedBox(
            quarterTurns: 3,
            child: Text(
              isCompleted ? "Completed" : "Pending",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: isCompleted ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
