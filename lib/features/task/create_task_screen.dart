import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/widgets/glass_background.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../models/task.dart';
import '../../models/category.dart';
import '../../providers/task_provider.dart';
import '../../providers/category_provider.dart';
import '../../core/widgets/ios_glass_pickers.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  final Task? initialTask;

  const CreateTaskScreen({super.key, this.initialTask});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _noteCtrl;

  late DateTime _date;
  late DateTime _startTime;
  late DateTime _endTime;
  int _reminder = 15;
  String? _categoryId;
  Color _selectedColor = const Color(0xFF7C4DFF);
  bool _saving = false;
  bool _categoryError = false;

  final _reminders = [5, 10, 15, 30];
  final _colors = [
    const Color(0xFF7C4DFF),
    const Color(0xFF40C4FF),
    const Color(0xFF69F0AE),
    const Color(0xFFFFD740),
    const Color(0xFFFF5252),
    const Color(0xFFFF6D00),
    const Color(0xFFE040FB),
    const Color(0xFF00BCD4),
  ];

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleCtrl = TextEditingController(text: task?.title ?? '');
    _noteCtrl = TextEditingController(text: task?.note ?? '');
    _date = task?.date ?? DateTime.now();
    _startTime = task?.startTime ?? DateTime.now();
    _endTime = task?.endTime ?? DateTime.now().add(const Duration(hours: 1));
    _reminder = task?.reminderMinutes ?? 15;
    _categoryId = task?.categoryId;
    _selectedColor =
        task != null ? Color(task.colorValue) : const Color(0xFF7C4DFF);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await IOSGlassPickers.showDatePicker(
      context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      title: 'Select Date',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await IOSGlassPickers.showTimePicker(
      context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startTime : _endTime),
      title: isStart ? 'Start Time' : 'End Time',
    );
    if (picked != null) {
      final base = _date;
      final dt =
          DateTime(base.year, base.month, base.day, picked.hour, picked.minute);
      setState(() {
        if (isStart) {
          _startTime = dt;
        } else {
          _endTime = dt;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_categoryId == null) {
      HapticFeedback.heavyImpact();
      setState(() => _categoryError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.category_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Please select a category for this task',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFF453A),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final task = Task(
      id: widget.initialTask?.id ?? const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      date: _date,
      startTime: _startTime,
      endTime: _endTime,
      reminderMinutes: _reminder,
      categoryId: _categoryId,
      colorValue: _selectedColor.toARGB32(),
      isCompleted: widget.initialTask?.isCompleted ?? false,
      createdAt: widget.initialTask?.createdAt ?? DateTime.now(),
    );

    if (widget.initialTask != null) {
      await ref.read(taskProvider.notifier).updateTask(task);
    } else {
      await ref.read(taskProvider.notifier).addTask(task);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ref.watch(categoryProvider);
    final isEdit = widget.initialTask != null;

    return GlassBackground(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // ─── Header ─────────────────────────────────────────────
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(10),
                          borderRadius: GlassTheme.radiusMedium,
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color:
                                isDark ? Colors.white : const Color(0xFF1A0A2E),
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isEdit ? 'Edit Task' : 'New Task',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : const Color(0xFF1A0A2E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ─── Title ───────────────────────────────────────────────
                  GlassTextField(
                    label: 'Task Title',
                    hint: 'What needs to be done?',
                    controller: _titleCtrl,
                    prefixIcon: Icons.title_rounded,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // ─── Note ────────────────────────────────────────────────
                  GlassTextField(
                    label: 'Note (optional)',
                    hint: 'Add a note...',
                    controller: _noteCtrl,
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // ─── Date ─────────────────────────────────────────────────
                  GlassTextField(
                    label: 'Date',
                    controller: TextEditingController(
                        text: DateFormat('EEE, d MMM yyyy').format(_date)),
                    prefixIcon: Icons.calendar_today_rounded,
                    readOnly: true,
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 16),

                  // ─── Times ────────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: GlassTextField(
                          label: 'Start Time',
                          controller: TextEditingController(
                              text: DateFormat('hh:mm a').format(_startTime)),
                          prefixIcon: Icons.play_arrow_rounded,
                          readOnly: true,
                          onTap: () => _pickTime(true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassTextField(
                          label: 'End Time',
                          controller: TextEditingController(
                              text: DateFormat('hh:mm a').format(_endTime)),
                          prefixIcon: Icons.stop_rounded,
                          readOnly: true,
                          onTap: () => _pickTime(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ─── Reminder Dropdown ────────────────────────────────────
                  _SectionLabel(label: 'Reminder', isDark: isDark),
                  const SizedBox(height: 8),
                  GlassContainer(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    borderRadius: GlassTheme.radiusMedium,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _reminder,
                        isExpanded: true,
                        dropdownColor: isDark
                            ? const Color(0xFF1A1A3E)
                            : Colors.white,
                        icon: Icon(Icons.expand_more_rounded,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.black.withValues(alpha: 0.4)),
                        style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF1A0A2E),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        items: _reminders
                            .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text('$m minutes before'),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _reminder = v ?? 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Category (Required) ──────────────────────────────────
                  Row(
                    children: [
                      _SectionLabel(label: 'Category', isDark: isDark),
                      const SizedBox(width: 4),
                      Text(
                        '*',
                        style: TextStyle(
                          color: _categoryError
                              ? const Color(0xFFFF453A)
                              : GlassTheme.accentPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (_categoryError) ...[
                        const SizedBox(width: 8),
                        const Text(
                          'Required',
                          style: TextStyle(
                            color: Color(0xFFFF453A),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: _categoryError
                        ? const EdgeInsets.all(8)
                        : EdgeInsets.zero,
                    decoration: _categoryError
                        ? BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(GlassTheme.radiusMedium),
                            border: Border.all(
                              color: const Color(0xFFFF453A)
                                  .withValues(alpha: 0.6),
                              width: 1.2,
                            ),
                            color:
                                const Color(0xFFFF453A).withValues(alpha: 0.06),
                          )
                        : null,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categories
                          .map((cat) => _CategoryChip(
                                cat: cat,
                                selected: _categoryId == cat.id,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _categoryId = cat.id;
                                    _categoryError = false;
                                  });
                                },
                                isDark: isDark,
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Color Picker ─────────────────────────────────────────
                  _SectionLabel(label: 'Task Color', isDark: isDark),
                  const SizedBox(height: 8),
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: GlassTheme.radiusMedium,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _colors
                          .map((c) => GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedColor = c),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: _selectedColor == c
                                        ? Border.all(
                                            color: Colors.white, width: 3)
                                        : null,
                                  ),
                                  child: _selectedColor == c
                                      ? const Icon(Icons.check,
                                          color: Colors.white, size: 18)
                                      : null,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ─── Save Button ──────────────────────────────────────────
                  GlassButton(
                    label: isEdit ? 'Update Task' : 'Create Task',
                    icon: isEdit ? Icons.edit_rounded : Icons.add_task_rounded,
                    onPressed: _save,
                    isLoading: _saving,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark
            ? Colors.white.withValues(alpha: 0.55)
            : Colors.black.withValues(alpha: 0.45),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final Category cat;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _CategoryChip({
    required this.cat,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(cat.colorValue);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.25)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(GlassTheme.radiusMedium),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          cat.name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? color
                : isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
