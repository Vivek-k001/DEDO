import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/models/task_model.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/widgets/appbar.dart';
import 'package:dedo/widgets/button.dart';
import 'package:dedo/widgets/text_form_field.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  String _startTime = DateFormat('hh:mm a').format(DateTime.now());

  String _endTime = DateFormat(
    'hh:mm a',
  ).format(DateTime.now().add(Duration(hours: 3)));

  int _selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20];

  String _selectedRepeat = 'None';
  List<String> repeatList = ["None", "Daily", "Weakly", "Monthly"];

  int _selectedColorIndex = 0;

  final List<Color> _colorOptions = [
    Colors.red,
    Colors.yellow,
    Colors.blue,
    Colors.green,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskSuccess) {
          Navigator.pop(context);
          DHelperFunctions.showSnackBar(
            title: "Success",
            message: "Task added successfully! ID: ${state.taskId}",
            icon: Icons.check_circle,
            context: context,
            bgColor: Colors.green,
          );
        } else if (state is TaskError) {
          DHelperFunctions.showSnackBar(
            title: "Error",
            message: "Error: ${state.message}",
            icon: Icons.error,
            context: context,
            bgColor: Colors.red,
          );
        }
      },
      child: Scaffold(
        appBar: DAppBar(
          showBackArrow: true,
          title: Center(
            child: Text(
              'Add Task',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(DSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Add Task",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: DSizes.spaceBtwItems),

                DTextFormField(
                  title: "Title",
                  hintText: "Enter your title",
                  prefixIcon: Icons.title,
                  controller: _titleController,
                ),

                DTextFormField(
                  title: "Note",
                  hintText: "Enter your note",
                  prefixIcon: Icons.note,
                  controller: _noteController,
                  maxlines: 3,
                ),

                DTextFormField(
                  title: "Date",
                  hintText: _selectedDate,
                  prefixIcon: FontAwesomeIcons.calendar,
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickerDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    setState(() {
                      _selectedDate = DateFormat(
                        'dd/MM/yyyy',
                      ).format(pickerDate ?? DateTime.now());
                    });
                  },
                ),

                Row(
                  children: [
                    Expanded(
                      child: DTextFormField(
                        hintText: _startTime,
                        prefixIcon: FontAwesomeIcons.clock,
                        title: "Start Time",
                        readOnly: true,
                        onTap: () async {
                          TimeOfDay? pickerStartTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          setState(() {
                            _startTime =
                                pickerStartTime != null
                                    ? pickerStartTime.format(context)
                                    : _startTime;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: DSizes.sm),
                    Expanded(
                      child: DTextFormField(
                        hintText: _endTime,
                        prefixIcon: FontAwesomeIcons.clock,
                        title: "End Time",
                        readOnly: true,
                        onTap: () async {
                          TimeOfDay? pickerEndTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          setState(() {
                            _endTime =
                                pickerEndTime != null
                                    ? pickerEndTime.format(context)
                                    : _endTime;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                DTextFormField(
                  hintText: "$_selectedRemind minutes early",
                  prefixIcon: Icons.closed_caption,
                  title: "Remind",
                  readOnly: true,
                  suffixWidget: DropdownButton(
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    iconSize: 32,
                    elevation: 4,
                    style: Theme.of(context).textTheme.titleSmall,
                    underline: Container(height: 0),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRemind = int.parse(newValue!);
                      });
                    },
                    items:
                        remindList.map<DropdownMenuItem<String>>((int value) {
                          return DropdownMenuItem<String>(
                            value: value.toString(),
                            child: Text(
                              '$value minutes early',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        }).toList(),
                  ),
                ),

                DTextFormField(
                  hintText: _selectedRepeat,
                  prefixIcon: Icons.repeat,
                  title: "Repeat",
                  readOnly: true,
                  suffixWidget: DropdownButton(
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    iconSize: 32,
                    elevation: 4,
                    style: Theme.of(context).textTheme.titleSmall,
                    underline: Container(height: 0),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRepeat = newValue!;
                      });
                    },
                    items:
                        repeatList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        }).toList(),
                  ),
                ),

                const SizedBox(height: DSizes.spaceBtwItems),

                Text('Color', style: Theme.of(context).textTheme.titleSmall),

                const SizedBox(height: DSizes.sm),

                Wrap(
                  children: List<Widget>.generate(_colorOptions.length, (
                    index,
                  ) {
                    final color = _colorOptions[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColorIndex = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: DSizes.sm),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: color,
                          child:
                              _selectedColorIndex == index
                                  ? Icon(
                                    Icons.done,
                                    color: Colors.white,
                                    size: DSizes.iconSm,
                                  )
                                  : null,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: DSizes.spaceBtwItems),

                DButton(
                  btnTitle: 'Create Task',
                  width: 140,
                  height: 50,
                  onTap: () => _validateAndSubmitTask(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _validateAndSubmitTask() {
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();

    if (title.isEmpty || note.isEmpty) {
      DHelperFunctions.showSnackBar(
        title: "Error",
        message: 'Please fill out all fields.',
        icon: Icons.error,
        bgColor: Colors.red,
        context: context,
      );
      return;
    }

    final task = TaskModel(
      note: note,
      title: title,
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      remind: _selectedRemind,
      repeat: _selectedRepeat,
      colorIndex: _selectedColorIndex,
      isCompleted: 0,
    );

    context.read<TaskBloc>().add(AddTask(task));
  }
}
