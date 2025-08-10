import 'dart:ui';
import 'package:dedo/widgets/container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/models/task_model.dart';
import 'package:dedo/screens/task_form/edit_task.dart';
import 'package:dedo/utils/helper_functions.dart';

// Function to show the bottom sheet with task options
Future<void> taskOptionsBottomSheet(BuildContext context, TaskModel task) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return Stack(
        children: [
          // Background blur and dim layer behind the sheet
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
          ),

          // Glassmorphic Bottom Sheet container aligned at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25), // Rounded top corners
              ),
              child: DContainer(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Button to toggle task completion status
                    _glassButton(
                      context: context,
                      icon:
                          task.isCompleted
                              ? Icons.pending_actions
                              : Icons.check,
                      text:
                          task.isCompleted
                              ? 'Mark as Pending'
                              : 'Mark as Completed',
                      onTap: () {
                        context.read<TaskBloc>().add(
                          ToggleTaskCompletion(task.id!, task.isCompleted),
                        );
                        Navigator.pop(context);
                      },
                    ),

                    _glassButton(
                      context: context,
                      icon: Icons.edit,
                      text: 'Edit Task',
                      onTap: () {
                        DHelperFunctions.navigateToScreen(
                          context,
                          EditTaskScreen(task: task),
                        );
                      },
                    ),

                    // Assuming you have this inside a widget build method
                    _glassButton(
                      context: context,
                      icon: Icons.delete,
                      text: "Delete Task",
                      textColor: Colors.red,
                      iconColor: Colors.red,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: const Text(
                                'Confirm Delete',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              content: const Text(
                                'Are you sure you want to delete this category?',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              actionsPadding: const EdgeInsets.only(
                                right: 8,
                                bottom: 8,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Perform delete
                                    context.read<TaskBloc>().add(
                                      DeleteTask(taskId: task.id!),
                                    );
                                    //
                                    // Close dialog and bottom sheet/page
                                    Navigator.of(
                                      dialogContext,
                                    ).pop(); // Close dialog
                                    Navigator.of(
                                      context,
                                    ).pop(); // Close the parent sheet/page
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 4),

                    _glassButton(
                      context: context,
                      icon: Icons.close,
                      text: 'Close',
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget _glassButton({
  required BuildContext context,
  required IconData icon,
  required String text,
  required VoidCallback onTap,
  Color textColor = Colors.black,
  Color iconColor = Colors.black,
  EdgeInsetsGeometry? padding,
  margin,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 16, color: textColor)),
          ),
        ],
      ),
    ),
  );
}
