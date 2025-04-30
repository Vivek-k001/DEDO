import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
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
    required this.colorIndex,
    required this.isCompleted,
  });

  final Color? bgColor;
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
        color: bgColor ?? _getColor(colorIndex),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
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
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(color: DColors.darkGrey),
              ),

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
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: DColors.darkGrey),
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
                ).textTheme.bodyLarge!.copyWith(color: DColors.darkGrey),
              ),
            ],
          ),

          const Spacer(),

          Container(height: 60, width: 1, color: DColors.darkGrey),

          const SizedBox(width: DSizes.sm),

          RotatedBox(
            quarterTurns: 3,
            child: Text(
              isCompleted ? "Completed" : "Pending",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: isCompleted ? Colors.greenAccent : Colors.deepOrange,
              ),
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
      default:
        return Colors.red;
    }
  }
}
