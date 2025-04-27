import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:dedo/bloc/theme/theme_bloc.dart';
import 'package:dedo/screens/add_task.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/constants/text.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime _selectedDate = DateTime.now();

    return Scaffold(
      appBar: DAppBar(
        title: Text(
          DTexts.appName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          /// Theme Switcher
          BlocBuilder<ThemeBloc, ThemeMode>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state == ThemeMode.dark
                      ? Icons.nightlight_round
                      : Icons.wb_sunny,
                  color: state == ThemeMode.dark ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  context.read<ThemeBloc>().add(
                    ThemeChangedEvent(state == ThemeMode.dark ? false : true),
                  );
                },
              );
            },
          ),

          /// Profile Icon
          IconButton(icon: Icon(Icons.person), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => DHelperFunctions.navigateToScreen(
              context,
              const AddTaskScreen(),
            ),
        tooltip: "Add Task",
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(DSizes.sm + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      DHelperFunctions.formatDate(DateTime.now()),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    // Text(
                    //   "Today",
                    //   style: Theme.of(context).textTheme.headlineSmall,
                    // ),
                  ],
                ),
                // DButton(
                //   btnTitle: "Add Task",
                //   width: 100,
                //   height: 60,
                //   onTap: () {},
                // ),
              ],
            ),
            const SizedBox(height: DSizes.spaceBtwItems),
            Container(
              margin: const EdgeInsets.only(top: DSizes.sm, left: DSizes.sm),
              child: DatePicker(
                DateTime.now(),
                height: 100,
                width: 80,
                initialSelectedDate: DateTime.now(),
                selectionColor: DColors.primary,
                selectedTextColor: Colors.white,
                dateTextStyle: Theme.of(context).textTheme.headlineSmall!,
                dayTextStyle: Theme.of(context).textTheme.bodyMedium!,
                monthTextStyle: Theme.of(context).textTheme.bodySmall!,
                onDateChange: (date) {
                  _selectedDate = date;
                  print(_selectedDate);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
