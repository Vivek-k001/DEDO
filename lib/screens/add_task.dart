import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/widgets/appbar.dart';
import 'package:dedo/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  String _selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  String _startTime = DateFormat('hh:mm a').format(DateTime.now());

  String _endTime = DateFormat(
    'hh:mm a',
  ).format(DateTime.now().add(Duration(hours: 3)));

  int _selectedRemind = 5;

  List<int> remindList = [0, 5, 10, 15, 20];

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
              Text(
                "Add Task",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: DSizes.spaceBtwItems),

              DTextFormField(
                title: "Title",
                hintText: "Enter your title",
                prefixIcon: Icons.title,
              ),

              DTextFormField(
                title: "Note",
                hintText: "Enter your note",
                prefixIcon: Icons.note,
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
                          child: Text(value.toString()),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
