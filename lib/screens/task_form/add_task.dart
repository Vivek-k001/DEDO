import 'package:dedo/screens/task_form/widgets/task_form.dart';
import 'package:dedo/widgets/appbar.dart';
import 'package:flutter/material.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DAppBar(
        showBackArrow: true,
        title: Text("Add Task", style: Theme.of(context).textTheme.titleLarge),
      ),
      body: const DTaskForm(isEditing: false),
    );
  }
}
