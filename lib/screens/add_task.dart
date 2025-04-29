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

  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DAppBar(showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DSizes.sm + 2),
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
              ),

              DTextFormField(
                title: "Date",
                hintText: _selectedDate.toString(),
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
                            value.toString(),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        );
                      }).toList(),
                ),
              ),

              DTextFormField(
                hintText: _selectedRepeat,
                prefixIcon: Icons.closed_caption,
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
                      repeatList.map<DropdownMenuItem<String>>((String? value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value!,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        );
                      }).toList(),
                ),
              ),

              SizedBox(height: DSizes.spaceBtwItems),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Color',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),

                      SizedBox(height: DSizes.sm),

                      Wrap(
                        children: List<Widget>.generate(3, (int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = index;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: DSizes.sm),
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor:
                                    index == 0
                                        ? Colors.red
                                        : index == 1
                                        ? Colors.yellow
                                        : Colors.blue,
                                child:
                                    _selectedColor == index
                                        ? Icon(
                                          Icons.done,
                                          color: Colors.white,
                                          size: DSizes.iconSm,
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
                    onTap: () => _validateData(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _validateData() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addTaskToDb();
      Navigator.pop(context);
    } else if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      DHelperFunctions.showSnackBar(
        message: 'All fields are required!',
        context: context,
      );
    }
  }

  _addTaskToDb() {
    final task = TaskModel(
      note: _noteController.text,
      title: _titleController.text,
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      remind: _selectedRemind,
      repeat: _selectedRepeat,
      color: _selectedColor,
      isCompleted: 0,
    );

    context.read<TaskBloc>().add(AddTask(task));
  }
}
