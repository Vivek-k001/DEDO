import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../core/widgets/glass_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/ios_glass_blue_button.dart';
import '../../../core/widgets/circular_glass_button.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../../models/track_list.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/track_list_provider.dart';
import '../../../providers/theme_provider.dart';

class CreateEditTrackListScreen extends ConsumerStatefulWidget {
  final TrackList? initialTrackList;

  const CreateEditTrackListScreen({super.key, this.initialTrackList});

  @override
  ConsumerState<CreateEditTrackListScreen> createState() =>
      _CreateEditTrackListScreenState();
}

class _CreateEditTrackListScreenState
    extends ConsumerState<CreateEditTrackListScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _customStatus1Ctrl;
  late final TextEditingController _customStatus2Ctrl;

  String? _selectedCategoryId;
  late int _selectedColor;
  late String _statusPresetKey;

  final List<int> _colorPalette = [
    0xFF007AFF, // iOS Blue
    0xFF5856D6, // Indigo
    0xFFAF52DE, // Purple
    0xFFFF2D55, // Pink
    0xFFFF9500, // Orange
    0xFF34C759, // Green
    0xFF00C7BE, // Teal
  ];

  static const Map<String, List<String>> _statusPresets = {
    'Pending / Completed': ['Pending', 'Completed'],
    'Paid / Pending': ['Pending', 'Paid'],
    'Present / Absent': ['Absent', 'Present'],
    'Received / Not Received': ['Not Received', 'Received'],
    'Custom': [],
  };

  @override
  void initState() {
    super.initState();
    final init = widget.initialTrackList;
    _titleCtrl = TextEditingController(text: init?.title ?? '');
    _descCtrl = TextEditingController(text: init?.description ?? '');

    _selectedCategoryId = init?.categoryId;
    _selectedColor = init?.colorValue ?? _colorPalette.first;

    if (init != null) {
      final opts = init.statusOptions;
      if (opts.length == 2 && opts.contains('Pending') && opts.contains('Completed')) {
        _statusPresetKey = 'Pending / Completed';
      } else if (opts.length == 2 && opts.contains('Pending') && opts.contains('Paid')) {
        _statusPresetKey = 'Paid / Pending';
      } else if (opts.length == 2 && opts.contains('Absent') && opts.contains('Present')) {
        _statusPresetKey = 'Present / Absent';
      } else if (opts.length == 2 && opts.contains('Not Received') && opts.contains('Received')) {
        _statusPresetKey = 'Received / Not Received';
      } else {
        _statusPresetKey = 'Custom';
      }
      _customStatus1Ctrl = TextEditingController(
          text: opts.isNotEmpty ? opts.first : 'Pending');
      _customStatus2Ctrl = TextEditingController(
          text: opts.length > 1 ? opts[1] : 'Completed');
    } else {
      _statusPresetKey = 'Pending / Completed';
      _customStatus1Ctrl = TextEditingController(text: 'Pending');
      _customStatus2Ctrl = TextEditingController(text: 'Completed');
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _customStatus1Ctrl.dispose();
    _customStatus2Ctrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    List<String> statusOptions;
    String defaultStatus;
    String completedStatus;

    if (_statusPresetKey == 'Custom') {
      final s1 = _customStatus1Ctrl.text.trim().isEmpty
          ? 'Pending'
          : _customStatus1Ctrl.text.trim();
      final s2 = _customStatus2Ctrl.text.trim().isEmpty
          ? 'Completed'
          : _customStatus2Ctrl.text.trim();
      statusOptions = [s1, s2];
      defaultStatus = s1;
      completedStatus = s2;
    } else {
      statusOptions = List<String>.from(_statusPresets[_statusPresetKey]!);
      defaultStatus = statusOptions.first;
      completedStatus = statusOptions.last;
    }

    final isEdit = widget.initialTrackList != null;

    if (isEdit) {
      final updated = widget.initialTrackList!;
      updated.title = _titleCtrl.text.trim();
      updated.description =
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();
      updated.categoryId = _selectedCategoryId;
      updated.colorValue = _selectedColor;
      updated.statusOptions = statusOptions;
      updated.defaultStatus = defaultStatus;
      updated.completedStatus = completedStatus;
      ref.read(trackListProvider.notifier).updateTrackList(updated);
      GlassToast.show(context, message: 'TrackList updated successfully');
    } else {
      final newTracker = TrackList(
        id: const Uuid().v4(),
        title: _titleCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        categoryId: _selectedCategoryId,
        colorValue: _selectedColor,
        statusOptions: statusOptions,
        defaultStatus: defaultStatus,
        completedStatus: completedStatus,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      ref.read(trackListProvider.notifier).addTrackList(newTracker);
      GlassToast.show(context, message: 'TrackList created successfully');
    }

    HapticFeedback.mediumImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final categories = ref.watch(categoryProvider);
    final isEdit = widget.initialTrackList != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        ambientColor: Color(_selectedColor),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    CircularGlassButton(
                      size: 44,
                      icon: CupertinoIcons.back,
                      isDark: isDark,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        isEdit ? 'Edit Tracker' : 'New TrackList',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1A0A2E),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form fields
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      GlassTextField(
                        label: 'Tracker Title',
                        hint: 'Enter tracker title...',
                        controller: _titleCtrl,
                        prefixIcon: CupertinoIcons.list_bullet,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      GlassTextField(
                        label: 'Description (Optional)',
                        hint: 'Enter description (optional)...',
                        controller: _descCtrl,
                        maxLines: 3,
                        prefixIcon: CupertinoIcons.text_quote,
                      ),
                      const SizedBox(height: 24),

                      // Status Mode / Preset Selection
                      Text(
                        'Status Style / Activity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.black.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _statusPresets.keys.map((preset) {
                          final isSelected = _statusPresetKey == preset;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _statusPresetKey = preset);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(_selectedColor)
                                        .withValues(alpha: isDark ? 0.35 : 0.2)
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : Colors.white.withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? Color(_selectedColor)
                                      : (isDark
                                          ? const Color(0xFF38383A)
                                          : const Color(0xFFE5E5EA)),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                preset,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? (isDark
                                          ? Colors.white
                                          : Color(_selectedColor))
                                      : (isDark
                                          ? Colors.white70
                                          : Colors.black87),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      if (_statusPresetKey == 'Custom') ...[
                        const SizedBox(height: 16),
                        GlassContainer(
                          padding: const EdgeInsets.all(16),
                          borderRadius: GlassTheme.radiusMedium,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Custom 2-State Status Labels:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: GlassTextField(
                                      label: 'Pending State',
                                      hint: 'e.g. Unpaid',
                                      controller: _customStatus1Ctrl,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GlassTextField(
                                      label: 'Completed State',
                                      hint: 'e.g. Paid',
                                      controller: _customStatus2Ctrl,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Category Selector (optional)
                      if (categories.isNotEmpty) ...[
                        Text(
                          'Category (Optional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.8)
                                : Colors.black.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildCategoryChip(
                                id: null,
                                name: 'None',
                                isSelected: _selectedCategoryId == null,
                                isDark: isDark,
                              ),
                              ...categories.map((cat) => _buildCategoryChip(
                                    id: cat.id,
                                    name: cat.name,
                                    isSelected: _selectedCategoryId == cat.id,
                                    isDark: isDark,
                                    color: Color(cat.colorValue),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Color Theme Picker
                      Text(
                        'Accent Color',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.black.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _colorPalette.map((col) {
                          final isSelected = _selectedColor == col;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedColor = col);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Color(col),
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        width: 2.5,
                                      )
                                    : null,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Color(col).withValues(alpha: 0.5),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 40),

                      // Save button
                      IosGlassBlueButton(
                        blueColor: Color(_selectedColor),
                        isDark: isDark,
                        useGradient: false,
                        onTap: _save,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEdit
                                  ? CupertinoIcons.check_mark_circled_solid
                                  : CupertinoIcons.plus_circle_fill,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEdit ? 'Save Changes' : 'Create Tracker',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String? id,
    required String name,
    required bool isSelected,
    required bool isDark,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedCategoryId = id;
            if (color != null) _selectedColor = color.toARGB32();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (color ?? GlassTheme.accentPrimary)
                    .withValues(alpha: isDark ? 0.3 : 0.16)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? (color ?? GlassTheme.accentPrimary)
                  : (isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA)),
              width: isSelected ? 1.5 : 0.8,
            ),
          ),
          child: Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? (isDark ? Colors.white : (color ?? GlassTheme.accentPrimary))
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}

