import 'package:dedo/screens/task_form/widgets/task_form.dart';
import 'package:dedo/widgets/appbar.dart';
import 'package:flutter/material.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom app bar with back arrow and title
      appBar: DAppBar(showBackArrow: true),
      // Body contains the task form widget with isEditing false (i.e. creating a new task)
      body: const DTaskForm(isEditing: false),
    );
  }
}
