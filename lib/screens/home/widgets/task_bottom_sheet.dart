import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/models/task_model.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<dynamic> taskOptionsBottomSheet(
  BuildContext context,
  TaskModel task,
  bool isCompleted,
) {
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(DSizes.md),
        height: DHelperFunctions.screenHeight(context) * 0.50,
        decoration: BoxDecoration(
          color:
              DHelperFunctions.isDarkMode(context)
                  ? DColors.darkerGrey
                  : DColors.lightGrey,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(DSizes.sm),
            topRight: Radius.circular(DSizes.sm),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DButton(
              onTap: () {
                context.read<TaskBloc>().add(
                  UpdateSingleField(
                    task.id!,
                    "isCompleted",
                    task.isCompleted == 0 ? 1 : 0,
                  ),
                );
                DHelperFunctions.showSnackBar(
                  title: "Success",
                  message: "Task updated successfully!",
                  icon: Icons.check_circle,
                  bgColor: Colors.green,
                  context: context,
                );
                Navigator.pop(context);
              },
              icon: Icons.pending,
              btnTitle: isCompleted ? "Mark as Pending" : "Mark as Completed",
              width: double.infinity,
              height: 55,
              btnColor: Colors.blue,
              showBorder: true,
            ),

            SizedBox(height: DSizes.spaceBtwItems),

            DButton(
              onTap: () {},
              icon: Icons.edit,
              btnTitle: "Edit Task",
              width: double.infinity,
              height: 55,
              btnColor: Colors.green,
              showBorder: true,
            ),

            SizedBox(height: DSizes.spaceBtwItems),

            DButton(
              onTap: () {
                context.read<TaskBloc>().add(DeleteTask(task.id!));
                DHelperFunctions.showSnackBar(
                  title: "Success",
                  message: "Task deleted successfully!",
                  icon: Icons.check_circle,
                  context: context,
                  bgColor: Colors.green,
                );
                Navigator.pop(context);
              },
              icon: Icons.delete,
              btnTitle: "Delete Task",
              width: double.infinity,
              height: 55,
              btnColor: Colors.red,
              showBorder: true,
            ),

            SizedBox(height: DSizes.spaceBtwItems),

            DButton(
              icon: Icons.close,
              onTap: () => Navigator.pop(context),
              btnTitle: "Close",
              width: double.infinity,
              height: 55,
              btnColor: Colors.white70,
              showBorder: true,
            ),

            SizedBox(height: DSizes.spaceBtwSections),
          ],
        ),
      );
    },
  );
}
