import 'package:dedo/bloc/category/category_bloc.dart';
import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/models/category_model.dart';
import 'package:dedo/models/task_model.dart';
import 'package:dedo/screens/add_task/widgets/add_task_header.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/widgets/appbar.dart';
import 'package:dedo/widgets/button.dart';
import 'package:dedo/widgets/dropdown.dart';
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
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  CategoryModel? _selectedCategory;

  String _selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  String startTime = DateFormat('hh:mm a').format(DateTime.now());

  String endTime = DateFormat(
    'hh:mm a',
  ).format(DateTime.now().add(Duration(hours: 3)));

  int _selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20, 30, 60];

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
  void initState() {
    context.read<CategoryBloc>().add(LoadCategories());
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskSuccess) {
          Navigator.pop(context);
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
      child: Scaffold(
        appBar: DAppBar(
          showBackArrow: true,
          title: Text(
            "Add Task",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(DSizes.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddTaskHeader(),

                  DTextFormField(
                    title: "Title",
                    hintText: "Enter your title",
                    prefixIcon: Icons.title,
                    controller: _titleController,
                  ),

                  DTextFormField(
                    title: "Note",
                    hintText: "Enter your note",
                    prefixIcon: Icons.description,
                    controller: _noteController,
                    maxlines: 2,
                  ),

                  DTextFormField(
                    title: "Date",
                    hintText: _selectedDate,
                    prefixIcon: FontAwesomeIcons.calendar,
                    readOnly: true,
                    suffixIcon: Icons.calendar_today,
                    onIconPressed: () async {
                      await _selectDateFromPicker(context);
                    },
                    onTap: () async {
                      await _selectDateFromPicker(context);
                    },
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: DTextFormField(
                          hintText: startTime,
                          prefixIcon: FontAwesomeIcons.clock,
                          title: "Start Time",
                          readOnly: true,
                          onTap: () async {
                            await _selectTimeFromPicker(context, true);
                          },
                        ),
                      ),

                      const SizedBox(width: DSizes.sm),

                      Expanded(
                        child: DTextFormField(
                          hintText: endTime,
                          prefixIcon: FontAwesomeIcons.clock,
                          title: "End Time",
                          readOnly: true,
                          onTap: () async {
                            await _selectTimeFromPicker(context, false);
                          },
                        ),
                      ),
                    ],
                  ),

                  DTextFormField(
                    hintText: "$_selectedRemind minutes before",
                    prefixIcon: Icons.notifications_active,
                    title: "Reminder",
                    readOnly: true,
                    suffixWidget: DDropdown(
                      value: _selectedRemind.toString(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRemind = int.parse(newValue!);
                        });
                      },
                      items:
                          remindList.map((int value) {
                            return DropdownMenuItem<String>(
                              value: value.toString(),
                              child: Text(
                                '$value minutes',
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
                    suffixWidget: DDropdown(
                      value: _selectedRepeat.toString(),
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

                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoading) {
                        return CircularProgressIndicator();
                      } else if (state is CategoryLoaded) {
                        return DTextFormField(
                          hintText:
                              _selectedCategory?.name ?? "Select Category",
                          prefixIcon: Icons.category,
                          title: "Category",
                          readOnly: true,
                          suffixWidget: DDropdown<CategoryModel>(
                            value: _selectedCategory,
                            onChanged: (CategoryModel? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            },
                            items:
                                state.categories
                                    .map<DropdownMenuItem<CategoryModel>>((
                                      CategoryModel category,
                                    ) {
                                      return DropdownMenuItem<CategoryModel>(
                                        value: category,
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 12,
                                              backgroundColor: Color(
                                                category.color,
                                              ),
                                            ),
                                            SizedBox(width: DSizes.md),
                                            Text(category.name),
                                          ],
                                        ),
                                      );
                                    })
                                    .toList(),
                          ),
                        );
                      } else if (state is CategoryError) {
                        return Text('Error: ${state.message}');
                      } else {
                        return const Text('No categories found.');
                      }
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: DSizes.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Color',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),

                        const SizedBox(height: DSizes.sm),

                        Wrap(
                          children: List<Widget>.generate(
                            _colorOptions.length,
                            (index) {
                              final color = _colorOptions[index];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedColorIndex = index;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: DSizes.sm,
                                  ),
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
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: DSizes.spaceBtwSections),

                  BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, state) {
                      final isLoading = state is TaskLoading;

                      return Center(
                        child: DButton(
                          btnTitle: isLoading ? 'Creating...' : 'Create Task',
                          width: 180,
                          height: 50,
                          onTap: isLoading ? null : _validateAndSubmitTask,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: DSizes.spaceBtwSections),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectTimeFromPicker(
    BuildContext context,
    bool isStartTime,
  ) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final formattedTime = pickedTime.format(context);
      setState(() {
        if (isStartTime) {
          startTime = formattedTime;
        } else {
          endTime = formattedTime;
        }
      });
    }
  }

  Future<void> _selectDateFromPicker(BuildContext context) async {
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

    if (_selectedCategory == null) {
      DHelperFunctions.showSnackBar(
        title: "Error",
        message: 'Please select a category',
        icon: Icons.error,
        bgColor: Colors.red,
        context: context,
      );
      return;
    }

    final start = DateFormat('hh:mm a').parse(startTime);
    final end = DateFormat('hh:mm a').parse(endTime);
    if (end.isBefore(start)) {
      DHelperFunctions.showSnackBar(
        title: "Error",
        message: 'End time must be after start time',
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
      startTime: startTime,
      endTime: endTime,
      remind: _selectedRemind,
      repeat: _selectedRepeat,
      colorIndex: _selectedColorIndex,
      categoryId: _selectedCategory!.id,
      isCompleted: false,
    );

    context.read<TaskBloc>().add(AddTask(task));
  }
}
