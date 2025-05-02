import 'package:dedo/models/task_model.dart';
import 'package:dedo/screens/task_form/widgets/task_form.dart';
import 'package:dedo/widgets/appbar.dart';
import 'package:flutter/material.dart';

class EditTaskScreen extends StatelessWidget {
  final TaskModel task;

  const EditTaskScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DAppBar(
        showBackArrow: true,
        title: Text("Edit Task", style: Theme.of(context).textTheme.titleLarge),
      ),

      body: DTaskForm(task: task, isEditing: true),
    );
  }
}
