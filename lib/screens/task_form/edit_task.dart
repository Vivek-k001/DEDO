import 'package:dedo/models/task_model.dart';
import 'package:dedo/screens/task_form/widgets/task_form.dart';
import 'package:dedo/widgets/appbar.dart';
import 'package:flutter/material.dart';

class EditTaskScreen extends StatelessWidget {
  // The task object to be edited, passed in from previous screen
  final TaskModel task;

  const EditTaskScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom app bar with back arrow and title "Edit Task"
      appBar: DAppBar(showBackArrow: true),

      // Body contains the task form widget with the task to edit and isEditing set to true
      body: DTaskForm(task: task, isEditing: true),
    );
  }
}
