import 'package:dedo/bloc/category/category_bloc.dart';
import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/models/category_model.dart';
import 'package:dedo/models/task_model.dart';
import 'package:dedo/screens/category/category.dart';
import 'package:dedo/screens/task_form/widgets/task_header.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/button.dart';
import 'package:dedo/widgets/dropdown.dart';
import 'package:dedo/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class DTaskForm extends StatefulWidget {
  const DTaskForm({super.key, this.task, required this.isEditing});

  final TaskModel? task; // Existing task to edit (if any)
  final bool isEditing; // Flag to indicate if form is editing or creating

  @override
  State<DTaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<DTaskForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  CategoryModel? _selectedCategory; // Currently selected category

  // Initial date formatted as dd/MM/yyyy (default to today)
  String _selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  // Start and end time formatted as hh:mm a
  String startTime = DateFormat('hh:mm a').format(DateTime.now());
  String endTime = DateFormat(
    'hh:mm a',
  ).format(DateTime.now().add(Duration(hours: 3))); // default end time 3h later

  int _selectedRemind = 5; // Reminder time in minutes
  List<int> remindList = [
    5,
    10,
    15,
    20,
    30,
    60,
  ]; // Options for reminder dropdown

  // Available colors to pick from
  final List<Color> _colorOptions = [
    Color(0xFFFFCDD2),
    Color(0xFFBBDEFB),
    Color(0xFFC8E6C9),
    Color(0xFFFFF9C4),
    Color(0xFFE1BEE7),
    Color(0xFFF8BBD0),
  ];

  Color _selectedColor = Color(0xFFFFCDD2); // Currently selected color

  @override
  void initState() {
    super.initState();

    // Load categories from CategoryBloc when form initializes
    context.read<CategoryBloc>().add(LoadCategories());

    // If editing an existing task, pre-fill the form fields with task data
    if (widget.isEditing && widget.task != null) {
      final task = widget.task!;

      _titleController.text = task.title;
      _noteController.text = task.note;
      _selectedDate = task.date;
      startTime = task.startTime;
      endTime = task.endTime;
      _selectedRemind = task.remind;
      _selectedColor = Color(task.color);

      // Try to set the selected category from loaded categories
      final categoryState = context.read<CategoryBloc>().state;
      if (categoryState is CategoryLoaded) {
        _selectedCategory = categoryState.categories.firstWhere(
          (category) => category.id == task.categoryId,
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free resources
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        // Listen for success or error states from TaskBloc after submission
        if (state is TaskSuccess) {
          if (isEditing) {
            Navigator.pop(context); // pop once if editing
          }
          Navigator.pop(context); // pop form screen after success
        }
        if (state is TaskError) {
          // Show error SnackBar if task submission failed
          DHelperFunctions.showSnackBar(
            title: "Error",
            message: state.message,
            icon: Icons.error,
            context: context,
            bgColor: Colors.red,
          );
        }
      },
      child: SingleChildScrollView(
        // Enable scrolling if form content overflows screen
        child: Padding(
          padding: const EdgeInsets.all(DSizes.md),
          child: Form(
            key: _formKey, // Form key to validate inputs if needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskHeader(
                  isEditing: isEditing,
                ), // Header widget showing form title
                // Title input field
                DTextFormField(
                  title: "Title",
                  hintText: "Enter your title",
                  prefixIcon: Icons.title,
                  controller: _titleController,
                ),

                // Note input field (multi-line)
                DTextFormField(
                  title: "Note",
                  hintText: "Enter your note",
                  prefixIcon: Icons.description,
                  controller: _noteController,
                  maxlines: 2,
                ),

                // Date picker field (read-only, with calendar icon)
                DTextFormField(
                  title: "Date",
                  hintText: _selectedDate,
                  prefixIcon: FontAwesomeIcons.calendar,
                  readOnly: true,
                  suffixIcon: Icons.calendar_today,
                  onIconPressed: () async {
                    await _selectDateFromPicker(context); // open date picker
                  },
                  onTap: () async {
                    await _selectDateFromPicker(
                      context,
                    ); // open date picker on tap too
                  },
                ),

                // Row for Start Time and End Time pickers side by side
                Row(
                  children: [
                    Expanded(
                      child: DTextFormField(
                        hintText: startTime,
                        prefixIcon: FontAwesomeIcons.clock,
                        title: "Start Time",
                        readOnly: true,
                        onTap: () async {
                          await _selectTimeFromPicker(
                            context,
                            true,
                          ); // select start time
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
                          await _selectTimeFromPicker(
                            context,
                            false,
                          ); // select end time
                        },
                      ),
                    ),
                  ],
                ),

                // Reminder dropdown inside a read-only text field
                DTextFormField(
                  hintText: "$_selectedRemind minutes before",
                  prefixIcon: Icons.notifications_active,
                  title: "Reminder",
                  readOnly: true,
                  suffixWidget: DDropdown(
                    value: _selectedRemind.toString(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRemind = int.parse(
                          newValue!,
                        ); // update selected reminder
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

                // Category selector using BlocBuilder and BlocListener
                BlocListener<CategoryBloc, CategoryState>(
                  listener: (context, state) {
                    // When categories are successfully added/updated, select first if none chosen
                    if (state is CategorySuccess) {
                      if (_selectedCategory == null &&
                          state.categories.isNotEmpty) {
                        setState(() {
                          _selectedCategory = state.categories.first;
                        });
                      }
                    }
                  },
                  child: BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoading) {
                        return CircularProgressIndicator(); // show loading spinner
                      } else if (state is CategoryLoaded) {
                        if (state.categories.isEmpty) {
                          // Show Add Category button if no categories exist
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: DSizes.sm + 2,
                            ),
                            child: Center(
                              child: DButton(
                                btnTitle: 'Add Category',
                                width: 180,
                                height: 50,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CategoryScreen(),
                                    ),
                                  );

                                  if (mounted) {
                                    // Reload categories after returning from add screen
                                    if (context.mounted) {
                                      context.read<CategoryBloc>().add(
                                        LoadCategories(),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        }

                        // Dropdown for selecting category from loaded list
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
                                _selectedCategory =
                                    newValue; // update selected category
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
                        return Text(
                          'Error: ${state.message}',
                        ); // show error if category load failed
                      } else {
                        return const Text(
                          'No categories found.',
                        ); // fallback message
                      }
                    },
                  ),
                ),

                // Color selector section with small colored circles user can tap to select
                Padding(
                  padding: const EdgeInsets.only(top: DSizes.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Color',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: DSizes.sm),

                      Wrap(
                        children: List<Widget>.generate(_colorOptions.length, (
                          index,
                        ) {
                          final color = _colorOptions[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor =
                                    color; // change selected color on tap
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: DSizes.sm),
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: color,
                                child:
                                    _selectedColor.toARGB32() ==
                                            color.toARGB32()
                                        ? Icon(
                                          Icons.done,
                                          color: Colors.black,
                                          size: DSizes.iconSm,
                                        )
                                        : null,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DSizes.spaceBtwSections),

                // Submit button with loading indicator and text depending on editing/creating state
                BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    final isLoading = state is TaskLoading;
                    return Center(
                      child: DButton(
                        btnTitle:
                            isLoading
                                ? isEditing
                                    ? 'Updating...'
                                    : 'Creating...'
                                : isEditing
                                ? 'Update Task'
                                : 'Create Task',
                        width: 180,
                        height: 50,
                        onTap:
                            isLoading
                                ? null
                                : _validateAndSubmitTask, // disable while loading
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
    );
  }

  // Show time picker dialog and update start or end time accordingly
  Future<void> _selectTimeFromPicker(
    BuildContext context,
    bool isStartTime,
  ) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      // Format time string in hh:mm a format (e.g., 08:30 PM)
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

  // Show date picker dialog and update _selectedDate accordingly
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

  // Validate form input and submit new or updated task to TaskBloc
  void _validateAndSubmitTask() {
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();

    if (title.isEmpty || note.isEmpty) {
      // Show error if title or note is empty
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
      // Show error if category not selected
      DHelperFunctions.showSnackBar(
        title: "Error",
        message: 'Please select a category',
        icon: Icons.error,
        bgColor: Colors.red,
        context: context,
      );
      return;
    }

    // Parse start and end times for comparison
    final start = DateFormat('hh:mm a').parse(startTime);
    final end = DateFormat('hh:mm a').parse(endTime);
    if (end.isBefore(start)) {
      // Show error if end time is earlier than start time
      DHelperFunctions.showSnackBar(
        title: "Error",
        message: 'End time must be after start time',
        icon: Icons.error,
        bgColor: Colors.red,
        context: context,
      );
      return;
    }

    // Construct TaskModel to submit
    final task = TaskModel(
      id: widget.isEditing ? widget.task?.id : null,
      note: note,
      title: title,
      date: _selectedDate,
      startTime: startTime,
      endTime: endTime,
      remind: _selectedRemind,
      color: _selectedColor.toARGB32(),
      categoryId: _selectedCategory!.id,
      isCompleted:
          widget.isEditing ? (widget.task?.isCompleted ?? false) : false,
      createdAt:
          widget.isEditing
              ? widget.task?.createdAt
              : DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      completedAt: widget.isEditing ? widget.task?.completedAt : null,
    );

    // Dispatch add or update event to TaskBloc
    if (widget.isEditing) {
      context.read<TaskBloc>().add(UpdateTask(task));
    } else {
      context.read<TaskBloc>().add(AddTask(task));
    }
  }
}
