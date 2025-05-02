import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/models/task_model.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/button.dart';
import 'package:dedo/widgets/container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<dynamic> taskOptionsBottomSheet(BuildContext context, TaskModel task) {
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskSuccess) {
            DHelperFunctions.showSnackBar(
              title: "Success",
              message: state.message,
              icon: Icons.check_circle,
              context: context,
              bgColor: Colors.green,
            );
          } else if (state is TaskError) {
            DHelperFunctions.showSnackBar(
              title: "Error",
              message: state.message,
              icon: Icons.error,
              context: context,
              bgColor: Colors.red,
            );
          }
        },
        child: DContainer(
          padding: const EdgeInsets.all(DSizes.md),
          // height: DHelperFunctions.screenHeight(context) * 0.50,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(DSizes.sm),
            topRight: Radius.circular(DSizes.sm),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DButton(
                onTap: () {
                  context.read<TaskBloc>().add(
                    ToggleTaskCompletion(task.id!, task.isCompleted),
                  );
                  Navigator.pop(context);
                },
                icon: task.isCompleted ? Icons.pending_actions : Icons.check,
                btnTitle:
                    task.isCompleted ? "Mark as Pending" : "Mark as Completed",
                width: double.infinity,
                height: 55,
                btnColor: Colors.blue,
              ),

              SizedBox(height: DSizes.spaceBtwSections),

              DButton(
                onTap: () {},
                icon: Icons.edit,
                btnTitle: "Edit Task",
                width: double.infinity,
                height: 55,
                btnColor: Colors.green,
              ),

              SizedBox(height: DSizes.spaceBtwSections),

              DButton(
                onTap: () {
                  context.read<TaskBloc>().add(DeleteTask(task.id!));
                  Navigator.pop(context);
                },
                icon: Icons.delete,
                btnTitle: "Delete Task",
                width: double.infinity,
                height: 55,
                btnColor: Colors.red,
              ),

              SizedBox(height: DSizes.spaceBtwSections),

              DButton(
                icon: Icons.close,
                onTap: () => Navigator.pop(context),
                btnTitle: "Close",
                width: double.infinity,
                height: 55,
                btnColor: Colors.white,
                textColor: Colors.black,
                showBorder: true,
              ),
            ],
          ),
        ),
      );
    },
  );
}
