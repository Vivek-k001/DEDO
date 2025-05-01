import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class DTaskTile extends StatelessWidget {
  const DTaskTile({
    super.key,
    required this.title,
    required this.note,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.repeat,
    required this.remind,
    required this.colorIndex,
    required this.isCompleted,
  });

  final String title, note;
  final String startTime, endTime, date, repeat;
  final int remind;
  final int colorIndex;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DSizes.md),
      margin: EdgeInsets.only(bottom: DSizes.sm + DSizes.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSizes.md),
        color: _getColor(colorIndex),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(color: DColors.light),
                ),

                SizedBox(height: DSizes.spaceBtwItems),

                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: DColors.lightContainer,
                    ),

                    SizedBox(width: DSizes.sm),

                    Text(
                      "$startTime - $endTime",
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(color: DColors.light),
                    ),
                  ],
                ),

                SizedBox(height: DSizes.sm + DSizes.xs),

                Text(
                  note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(color: DColors.light),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(height: 60, width: 2, color: Colors.grey.shade200),

                const SizedBox(width: DSizes.md),

                RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    isCompleted ? "Completed" : "Pending",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: isCompleted ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _getColor(int colorIndex) {
    switch (colorIndex) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.purple;
      default:
        return Colors.red;
    }
  }
}
