import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/widgets/glass_background.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../providers/task_provider.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  final bool isRootTab;

  const CategoryScreen({super.key, this.isRootTab = false});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  static const List<Color> _presetColors = [
    Color(0xFF007AFF), // iOS System Blue
    Color(0xFF5856D6), // iOS System Indigo
    Color(0xFF7C4DFF), // Deep Purple
    Color(0xFFAF52DE), // iOS Purple
    Color(0xFFFF2D55), // iOS Pink
    Color(0xFFFF3B30), // iOS System Red
    Color(0xFFFF9500), // iOS System Orange
    Color(0xFFFFCC00), // iOS System Yellow
    Color(0xFF34C759), // iOS System Green
    Color(0xFF00C7BE), // iOS Teal
    Color(0xFF30B0C7), // iOS Cyan
    Color(0xFF8E8E93), // iOS System Gray
  ];

  void _openCategoryEditorModal({Category? category}) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = category != null;

    final nameCtrl = TextEditingController(text: category?.name ?? '');
    Color selectedColor =
        category != null ? Color(category.colorValue) : _presetColors.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            final bottomInset = MediaQuery.of(modalCtx).viewInsets.bottom;
            final sheetBg =
                isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
            final inputBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
            final textColor = isDark ? Colors.white : Colors.black;
            final subtextColor = isDark
                ? const Color(0xFF8E8E93)
                : const Color(0xFF636366);

            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: sheetBg.withValues(alpha: 0.94),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28)),
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.14)
                              : Colors.black.withValues(alpha: 0.08),
                          width: 0.8,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // iOS drag pill
                        Center(
                          child: Container(
                            width: 36,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.22)
                                  : Colors.black.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title Bar
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: selectedColor.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isEdit
                                    ? Icons.edit_rounded
                                    : CupertinoIcons.add,
                                color: selectedColor,
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isEdit ? 'Edit Category' : 'New Category',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  Text(
                                    isEdit
                                        ? 'Update category name and accent color'
                                        : 'Organize your tasks under this category',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subtextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => Navigator.pop(modalCtx),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  CupertinoIcons.xmark,
                                  size: 15,
                                  color: subtextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Input Field
                        Text(
                          'CATEGORY NAME',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: subtextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF38383A)
                                  : const Color(0xFFE5E5EA),
                              width: 0.8,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          child: TextField(
                            controller: nameCtrl,
                            autofocus: !isEdit,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                            decoration: InputDecoration(
                              icon: Icon(
                                CupertinoIcons.tag_fill,
                                size: 18,
                                color: selectedColor,
                              ),
                              hintText: 'e.g. Work, Study, Health...',
                              hintStyle: TextStyle(
                                color: subtextColor.withValues(alpha: 0.7),
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Color Palette
                        Text(
                          'COLOR ACCENT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: subtextColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _presetColors.map((c) {
                            final isPicked =
                                selectedColor.toARGB32() == c.toARGB32();
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setModalState(() => selectedColor = c);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isPicked
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: isPicked ? 3 : 0,
                                  ),
                                  boxShadow: isPicked
                                      ? [
                                          BoxShadow(
                                            color: c.withValues(alpha: 0.5),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: isPicked
                                    ? const Icon(
                                        CupertinoIcons.checkmark_alt,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 28),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                color: isDark
                                    ? const Color(0xFF2C2C2E)
                                    : const Color(0xFFE5E5EA),
                                borderRadius: BorderRadius.circular(14),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pop(modalCtx);
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CupertinoButton(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                color: selectedColor,
                                borderRadius: BorderRadius.circular(14),
                                onPressed: () async {
                                  final name = nameCtrl.text.trim();
                                  if (name.isEmpty) {
                                    HapticFeedback.heavyImpact();
                                    return;
                                  }
                                  HapticFeedback.mediumImpact();

                                  if (isEdit) {
                                    final updated = Category(
                                      id: category.id,
                                      name: name,
                                      colorValue: selectedColor.toARGB32(),
                                    );
                                    await ref
                                        .read(categoryProvider.notifier)
                                        .updateCategory(updated);
                                  } else {
                                    final created = Category(
                                      id: const Uuid().v4(),
                                      name: name,
                                      colorValue: selectedColor.toARGB32(),
                                    );
                                    await ref
                                        .read(categoryProvider.notifier)
                                        .addCategory(created);
                                  }

                                  if (modalCtx.mounted) {
                                    Navigator.pop(modalCtx);
                                  }
                                },
                                child: Text(
                                  isEdit ? 'Save Changes' : 'Create Category',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteCategory(Category category) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = GlassTheme.cardBg(isDark);
    final borderColor = GlassTheme.borderColor(isDark);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Delete Category',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim, secondaryAnim) {
        final springCurved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Full-screen Backdrop Blur (Telegram / iOS style)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(ctx),
                  child: FadeTransition(
                    opacity: anim,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.55)
                            : Colors.black.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ),
              ),

              // Centered Dialog with Spring Scale
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.88, end: 1.0)
                        .animate(springCurved),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: anim,
                        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor, width: 0.8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x38000000),
                              blurRadius: 36,
                              offset: Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: GlassTheme.accentDanger
                                    .withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.trash_fill,
                                color: GlassTheme.accentDanger,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Delete "${category.name}"?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tasks assigned to this category will keep their details, but the category tag will be removed.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: isDark
                                    ? const Color(0xFF8E8E93)
                                    : const Color(0xFF636366),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                // Cancel button
                                Expanded(
                                  child: CupertinoButton(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 13),
                                    color: isDark
                                        ? const Color(0xFF2C2C2E)
                                        : const Color(0xFFE5E5EA),
                                    borderRadius: BorderRadius.circular(14),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.pop(ctx);
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Delete button
                                Expanded(
                                  child: CupertinoButton(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 13),
                                    color: GlassTheme.accentDanger,
                                    borderRadius: BorderRadius.circular(14),
                                    onPressed: () {
                                      HapticFeedback.heavyImpact();
                                      ref
                                          .read(categoryProvider.notifier)
                                          .deleteCategory(category.id);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Show actions overlay for category
  void _showCategoryContextMenu({
    required BuildContext context,
    required Category category,
    required int taskCount,
    required int completedCount,
  }) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = Color(category.colorValue);

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (ctx, anim, secondaryAnim) {
          final springCurved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeInCubic,
          );

          final cardBg = GlassTheme.cardBg(isDark);
          final borderColor = GlassTheme.borderColor(isDark);

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Backdrop blur
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.pop(ctx),
                    child: FadeTransition(
                      opacity: anim,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.55)
                              : Colors.black.withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                  ),
                ),

                // Center Card Preview & Action Pill
                SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.85, end: 1.0)
                            .animate(springCurved),
                        child: FadeTransition(
                          opacity: CurvedAnimation(
                            parent: anim,
                            curve:
                                const Interval(0.0, 0.7, curve: Curves.easeOut),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ── Category Card Preview ──
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                      color: borderColor, width: 0.8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x40000000),
                                      blurRadius: 36,
                                      offset: Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color:
                                                catColor.withValues(alpha: 0.16),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: catColor
                                                  .withValues(alpha: 0.35),
                                              width: 1.2,
                                            ),
                                          ),
                                          child: Icon(
                                            CupertinoIcons.tag_fill,
                                            color: catColor,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                category.name,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: -0.3,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '$taskCount total • $completedCount completed',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: isDark
                                                      ? const Color(0xFF8E8E93)
                                                      : const Color(0xFF636366),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    // Progress Bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: taskCount == 0
                                            ? 0.0
                                            : (completedCount / taskCount)
                                                .clamp(0.0, 1.0),
                                        minHeight: 6,
                                        backgroundColor: isDark
                                            ? const Color(0xFF2C2C2E)
                                            : const Color(0xFFE5E5EA),
                                        valueColor:
                                            AlwaysStoppedAnimation(catColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ── iOS / Telegram Action Menu ──
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: borderColor, width: 0.8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x35000000),
                                      blurRadius: 28,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Column(
                                    children: [
                                      // Edit Option
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pop(ctx);
                                            _openCategoryEditorModal(
                                                category: category);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 18, vertical: 15),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.edit_rounded,
                                                  color:
                                                      GlassTheme.accentPrimary,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Text(
                                                    'Edit Category',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: isDark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Icon(
                                                  CupertinoIcons
                                                      .chevron_forward,
                                                  size: 16,
                                                  color: isDark
                                                      ? const Color(0xFF8E8E93)
                                                      : const Color(0xFFC7C7CC),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 0.6,
                                        indent: 52,
                                        color: borderColor,
                                      ),
                                      // Delete Option
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pop(ctx);
                                            _confirmDeleteCategory(category);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 18, vertical: 15),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  CupertinoIcons.trash,
                                                  color:
                                                      GlassTheme.accentDanger,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 14),
                                                Expanded(
                                                  child: Text(
                                                    'Delete Category',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: GlassTheme
                                                          .accentDanger,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ref.watch(categoryProvider);
    final tasks = ref.watch(taskProvider);

    final cardBg = GlassTheme.cardBg(isDark);
    final borderColor = GlassTheme.borderColor(isDark);
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF636366);

    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.isCompleted).length;

    final content = SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Header ──────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (!widget.isRootTab && Navigator.canPop(context)) ...[
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: borderColor, width: 0.8),
                            ),
                            child: Icon(
                              CupertinoIcons.chevron_back,
                              color: textColor,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: textColor,
                          ),
                        ),
                      ),
                      // Telegram / iOS style pill action button to add category
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        color: GlassTheme.accentPrimary,
                        borderRadius: BorderRadius.circular(20),
                        onPressed: () => _openCategoryEditorModal(),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.add,
                                size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ─── Overview Hero Card (iOS grouped card) ──────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor, width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.35)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF007AFF),
                                Color(0xFF5856D6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF007AFF)
                                    .withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.square_grid_2x2_fill,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${categories.length} Categories',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '$totalTasks total tasks • $completedTasks completed',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ALL CATEGORIES',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.9,
                          color: subtextColor,
                        ),
                      ),
                      Text(
                        'Swipe or long press',
                        style: TextStyle(
                          fontSize: 11,
                          color: subtextColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Categories List / Grouped iOS Container ──────────────
          if (categories.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1C1C1E)
                              : const Color(0xFFF2F2F7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.folder_badge_plus,
                          size: 42,
                          color: subtextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Categories Yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap "+ Add" above to create your first category',
                        style: TextStyle(
                          fontSize: 13,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cat = categories[index];
                    final catColor = Color(cat.colorValue);
                    final catTasks =
                        tasks.where((t) => t.categoryId == cat.id).toList();
                    final catTaskCount = catTasks.length;
                    final catCompletedCount =
                        catTasks.where((t) => t.isCompleted).length;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CategoryItemCard(
                        category: cat,
                        color: catColor,
                        taskCount: catTaskCount,
                        completedCount: catCompletedCount,
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        onTap: () {
                          _openCategoryEditorModal(category: cat);
                        },
                        onLongPress: () {
                          _showCategoryContextMenu(
                            context: context,
                            category: cat,
                            taskCount: catTaskCount,
                            completedCount: catCompletedCount,
                          );
                        },
                        onEdit: () {
                          _openCategoryEditorModal(category: cat);
                        },
                        onDelete: () {
                          _confirmDeleteCategory(cat);
                        },
                      ),
                    );
                  },
                  childCount: categories.length,
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.isRootTab) {
      return content;
    }

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: content,
      ),
    );
  }
}

// Category item card
class _CategoryItemCard extends StatefulWidget {
  final Category category;
  final Color color;
  final int taskCount;
  final int completedCount;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color textColor;
  final Color subtextColor;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryItemCard({
    required this.category,
    required this.color,
    required this.taskCount,
    required this.completedCount,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.textColor,
    required this.subtextColor,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_CategoryItemCard> createState() => _CategoryItemCardState();
}

class _CategoryItemCardState extends State<_CategoryItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _springCtrl;
  late Animation<double> _springAnim;
  double _dragOffset = 0.0;
  static const double _actionThreshold = 75.0;
  bool _hasHapticTicked = false;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() => setState(() {}));
    _springAnim = Tween<double>(begin: 0.0, end: 0.0).animate(_springCtrl);
  }

  @override
  void dispose() {
    _springCtrl.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_springCtrl.isAnimating) return;
    setState(() {
      _dragOffset =
          (_dragOffset + details.delta.dx * 0.85).clamp(-120.0, 120.0);
      if (_dragOffset.abs() >= _actionThreshold && !_hasHapticTicked) {
        HapticFeedback.mediumImpact();
        _hasHapticTicked = true;
      } else if (_dragOffset.abs() < _actionThreshold) {
        _hasHapticTicked = false;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() >= _actionThreshold) {
      if (_dragOffset > 0) {
        // Swiped right -> Edit action
        HapticFeedback.lightImpact();
        widget.onEdit();
      } else {
        // Swiped left -> Delete action
        HapticFeedback.heavyImpact();
        widget.onDelete();
      }
    }
    _animateBack();
  }

  void _animateBack() {
    _hasHapticTicked = false;
    _springAnim = Tween<double>(begin: _dragOffset, end: 0.0).animate(
      CurvedAnimation(
        parent: _springCtrl,
        curve: Curves.easeOutBack, // Telegram spring rebound
      ),
    );
    _springCtrl.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _dragOffset = 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentOffset =
        _springCtrl.isAnimating ? _springAnim.value : _dragOffset;
    final progress = widget.taskCount == 0
        ? 0.0
        : (widget.completedCount / widget.taskCount).clamp(0.0, 1.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background swipe actions (Edit on right swipe, Delete on left swipe)
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                // Swiping right: Edit
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    color: GlassTheme.accentPrimary,
                    child: const Row(
                      children: [
                        Icon(CupertinoIcons.pencil,
                            color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Swiping left: Delete
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: GlassTheme.accentDanger,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(CupertinoIcons.trash,
                            color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Foreground Card
        Transform.translate(
          offset: Offset(currentOffset, 0),
          child: GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: widget.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.borderColor, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDark
                        ? Colors.black.withValues(alpha: 0.28)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Progress ring around category icon
                      SizedBox(
                        width: 46,
                        height: 46,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: widget.taskCount == 0 ? 0.0 : progress,
                              strokeWidth: 2.4,
                              backgroundColor: widget.color.withValues(alpha: 0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                              strokeCap: StrokeCap.round,
                            ),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: widget.color.withValues(alpha: 0.16),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.tag_fill,
                                color: widget.color,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Name & Task counter
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: widget.textColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.taskCount == 0
                                  ? 'No tasks assigned'
                                  : '${widget.taskCount} tasks • ${widget.completedCount} done',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: widget.subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Percent badge or action chevron
                      if (widget.taskCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: widget.color,
                            ),
                          ),
                        )
                      else
                        Icon(
                          CupertinoIcons.chevron_forward,
                          size: 16,
                          color: widget.subtextColor.withValues(alpha: 0.5),
                        ),
                    ],
                  ),

                  // Progress bar indicator if tasks exist
                  if (widget.taskCount > 0) ...[
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: widget.isDark
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFE5E5EA),
                        valueColor: AlwaysStoppedAnimation(widget.color),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
