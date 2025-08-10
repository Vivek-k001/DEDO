import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/container.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';

class DDateTimeline extends StatelessWidget {
  // Optional callback function to handle date changes
  final Function(DateTime)? onDateChange;

  const DDateTimeline({super.key, this.onDateChange});

  @override
  Widget build(BuildContext context) {
    // Determine if dark mode is enabled
    final isDark = DHelperFunctions.isDarkMode(context);

    return DContainer(
      // EasyDateTimeLine widget from easy_date_timeline package
      child: EasyDateTimeLine(
        // Set initial date to current date
        initialDate: DateTime.now(),

        // Color for the active (selected) date
        activeColor: DColors.primary,

        // Header styling and behavior
        headerProps: EasyHeaderProps(
          // Format for displaying the full date (day-month-year)
          dateFormatter: DateFormatter.fullDateDMY(),

          // Month picker style - switcher type
          monthPickerType: MonthPickerType.switcher,

          // Style for selected date in the header
          selectedDateStyle: Theme.of(context).textTheme.titleSmall,

          // Style for month text in the header
          monthStyle: Theme.of(context).textTheme.titleSmall,
        ),

        // Day styling and properties
        dayProps: EasyDayProps(
          // Structure to show day number and day string (e.g., 'Mon')
          dayStructure: DayStructure.dayNumDayStr,

          // Style for inactive days (not selected)
          inactiveDayStyle: DayStyle(
            dayNumStyle: Theme.of(context).textTheme.titleLarge,
            dayStrStyle: Theme.of(context).textTheme.bodySmall,
            decoration: BoxDecoration(
              // Background color depending on theme
              color:
                  isDark
                      ? DColors.darkerGrey
                      : const Color.fromARGB(255, 230, 233, 255),
              borderRadius: BorderRadius.circular(48.0),
            ),
          ),

          // Size of each day item in timeline
          height: 56.0,
          width: 56.0,

          // Style for active (selected) day
          activeDayStyle: DayStyle(
            dayNumStyle: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(color: Colors.black),
            dayStrStyle: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: Colors.black),
          ),

          // Highlight color for today with opacity
          todayHighlightColor: DColors.primary.withValues(alpha: 0.4),

          // Style for today (current date)
          todayStyle: DayStyle(
            dayNumStyle: Theme.of(context).textTheme.titleLarge,
            dayStrStyle: Theme.of(context).textTheme.bodySmall,
          ),
        ),

        // Callback when a date is selected or changed
        onDateChange: onDateChange,
      ),
    );
  }
}
