import 'package:dedo/controllers/task_controller.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/widgets/appbar.dart';
import 'package:dedo/widgets/button.dart';
import 'package:dedo/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dedo/models/taskmodel.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _startTime = DateFormat('hh:mm a').format(DateTime.now());
  String _endTime = DateFormat(
    'hh:mm a',
  ).format(DateTime.now().add(Duration(hours: 3)));

  int _selectedRemind = 5;
  List<int> remindList = [0, 5, 10, 15, 20];

  String _selectedRepeat = 'None';
  List<String> repeatList = ["None", "Daily", "Weakly", "Monthly"];

  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task added successfully! ID: ${state.taskId}'),
            ),
          );
        } else if (state is TaskFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: DAppBar(showBackArrow: true),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(DSizes.sm + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add Task",
                  style: Theme.of(context).textTheme.headlineSmall,
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
                ),

                DTextFormField(
                  title: "Date",
                  hintText: DateFormat('dd/MM/yyyy').format(_selectedDate),
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
                      _selectedDate = pickerDate ?? DateTime.now();
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
                          if (pickerStartTime != null) {
                            final now = DateTime.now();
                            final dt = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              pickerStartTime.hour,
                              pickerStartTime.minute,
                            );
                            setState(() {
                              _startTime = DateFormat('hh:mm a').format(dt);
                            });
                          }
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
                          if (pickerEndTime != null) {
                            final now = DateTime.now();
                            final dt = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              pickerEndTime.hour,
                              pickerEndTime.minute,
                            );
                            setState(() {
                              _endTime = DateFormat('hh:mm a').format(dt);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),

                DTextFormField(
                  hintText: "$_selectedRemind minutes early",
                  prefixIcon: Icons.closed_caption,
                  title: "Remind",
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
                        remindList.map((int value) {
                          return DropdownMenuItem<String>(
                            value: value.toString(),
                            child: Text(value.toString()),
                          );
                        }).toList(),
                  ),
                ),

                DTextFormField(
                  hintText: "$_selectedRepeat",
                  prefixIcon: Icons.repeat,
                  title: "Repeat",
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
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }).toList(),
                  ),
                ),

                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Color',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          children: List<Widget>.generate(3, (index) {
                            final color =
                                index == 0
                                    ? DColors.primary
                                    : index == 1
                                    ? DColors.secondary
                                    : Colors.red;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = index;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: color,
                                  child:
                                      _selectedColor == index
                                          ? Icon(
                                            Icons.done,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                          : Container(),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    DButton(
                      btnTitle: 'Create Task',
                      width: 140,
                      height: 50,
                      onTap: () => _validateForm(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _validateForm(BuildContext context) {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addTaskToBloc(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addTaskToBloc(BuildContext context) {
    final task = Task(
      note: _noteController.text,
      title: _titleController.text,
      date: DateFormat.yMd().format(_selectedDate),
      startTime: _startTime,
      endTime: _endTime,
      remind: _selectedRemind,
      repeat: _selectedRepeat,
      color: _selectedColor,
      isCompleted: 0,
    );

    context.read<TaskBloc>().add(AddTaskEvent(task));
  }
}
