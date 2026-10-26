import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../models/task.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../core/widgets/glass_toast.dart';
import 'telegram_context_menu.dart';

// Task list item card
class TaskCard extends ConsumerStatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback? onCelebration;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onCelebration,
  });

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  bool _hasHapticTicked = false;
  bool _isCheckboxPressed = false;
  late final AnimationController _springCtrl;
  late Animation<double> _springAnim;

  // Thresholds
  static const double _actionThreshold = 74.0;
  static const double _maxSwipe = 140.0;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
  }

  @override
  void dispose() {
    _springCtrl.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      // Elastic resistance curve (diminishing returns as you pull further)
      final rawDelta = details.primaryDelta ?? 0;
      double newOffset = _dragOffset + rawDelta;

      if (newOffset.abs() > _actionThreshold) {
        final overflow = newOffset.abs() - _actionThreshold;
        final dampened = _actionThreshold + (overflow * 0.38); // Physical resistance
        newOffset = newOffset > 0 ? dampened : -dampened;
      }

      newOffset = newOffset.clamp(-_maxSwipe, _maxSwipe);
      _dragOffset = newOffset;

      // Haptic tick precisely as threshold is passed
      if (_dragOffset.abs() >= _actionThreshold && !_hasHapticTicked) {
        _hasHapticTicked = true;
        HapticFeedback.mediumImpact();
      } else if (_dragOffset.abs() < _actionThreshold && _hasHapticTicked) {
        _hasHapticTicked = false;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() >= _actionThreshold) {
      if (_dragOffset > 0) {
        // Swiped right -> Toggle Complete with celebration & iOS Dynamic Island feedback
        final task = widget.task;
        final willComplete = !task.isCompleted;

        if (willComplete) {
          HapticFeedback.mediumImpact();
          widget.onCelebration?.call();
          GlassToast.show(
            context,
            message: 'Completed "${task.title}"',
            icon: CupertinoIcons.checkmark_seal_fill,
            iconColor: GlassTheme.accentSuccess,
            actionLabel: 'UNDO',
            onAction: () {
              HapticFeedback.lightImpact();
              ref.read(taskProvider.notifier).toggleComplete(task.id);
            },
          );
        } else {
          HapticFeedback.lightImpact();
        }
        ref.read(taskProvider.notifier).toggleComplete(task.id);
      } else {
        // Swiped left -> Delete with haptic and top GlassToast Undo option
        HapticFeedback.heavyImpact();
        final deletedTask = widget.task;
        ref.read(taskProvider.notifier).deleteTask(deletedTask.id);
        GlassToast.show(
          context,
          message: 'Deleted "${deletedTask.title}"',
          icon: CupertinoIcons.trash,
          iconColor: GlassTheme.accentDanger,
          actionLabel: 'UNDO',
          onAction: () {
            HapticFeedback.mediumImpact();
            ref.read(taskProvider.notifier).addTask(deletedTask);
          },
        );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final task = widget.task;
    final categories = ref.watch(categoryProvider);
    final category =
        categories.cast().where((c) => c.id == task.categoryId).firstOrNull;
    final catColor =
        category != null ? Color(category.colorValue) : GlassTheme.accentPrimary;
    final taskColor = Color(task.colorValue);

    final cardBg = GlassTheme.cardBg(isDark);
    final borderColor = GlassTheme.borderColor(isDark);

    // Current horizontal shift
    final currentOffset = _springCtrl.isAnimating ? _springAnim.value : _dragOffset;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Action Buttons (Left = Done, Right = Delete)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(GlassTheme.radiusMedium),
              child: Row(
                children: [
                  // Swiping right: Done Action
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 24),
                      color: GlassTheme.accentSuccess,
                      child: Row(
                        children: [
                          Icon(
                            task.isCompleted
                                ? CupertinoIcons.arrow_uturn_left
                                : CupertinoIcons.checkmark_circle_fill,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            task.isCompleted ? 'Pending' : 'Done',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Swiping left: Delete Action
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      color: GlassTheme.accentDanger,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            CupertinoIcons.trash_fill,
                            color: Colors.white,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Card with Liquid Horizontal Offset & Long-press context menu
          AnimatedBuilder(
            animation: _springCtrl,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(currentOffset, 0),
                child: child,
              );
            },
            child: GestureDetector(
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              onTap: () {
                showIosTelegramContextMenu(
                  context: context,
                  task: task,
                  categoryColor: catColor,
                  categoryName: category?.name,
                  onToggleComplete: () =>
                      ref.read(taskProvider.notifier).toggleComplete(task.id),
                  onEdit: widget.onTap,
                  onDelete: () =>
                      ref.read(taskProvider.notifier).deleteTask(task.id),
                );
              },
              onLongPress: () {
                showIosTelegramContextMenu(
                  context: context,
                  task: task,
                  categoryColor: catColor,
                  categoryName: category?.name,
                  onToggleComplete: () =>
                      ref.read(taskProvider.notifier).toggleComplete(task.id),
                  onEdit: widget.onTap,
                  onDelete: () =>
                      ref.read(taskProvider.notifier).deleteTask(task.id),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GlassTheme.radiusMedium),
                  border: Border.all(color: borderColor, width: 0.8),
                  boxShadow: GlassTheme.glassShadow(isDark),
                ),
                child: Row(
                  children: [
                    // Task Custom Color Accent (Rounded glowing pill)
                    Container(
                      width: 3.5,
                      height: 28,
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? taskColor.withValues(alpha: 0.35)
                            : taskColor,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: task.isCompleted
                            ? null
                            : [
                                BoxShadow(
                                  color: taskColor.withValues(alpha: 0.45),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Interactive Checkbox with Immediate Touch Haptic & Micro-pop
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) {
                        HapticFeedback.lightImpact();
                        setState(() => _isCheckboxPressed = true);
                      },
                      onTapUp: (_) {
                        setState(() => _isCheckboxPressed = false);
                      },
                      onTapCancel: () {
                        setState(() => _isCheckboxPressed = false);
                      },
                      onTap: () {
                        final willComplete = !task.isCompleted;
                        if (willComplete) {
                          HapticFeedback.mediumImpact();
                          widget.onCelebration?.call();
                          GlassToast.show(
                            context,
                            message: 'Completed "${task.title}"',
                            icon: CupertinoIcons.checkmark_seal_fill,
                            iconColor: GlassTheme.accentSuccess,
                            actionLabel: 'UNDO',
                            onAction: () {
                              HapticFeedback.lightImpact();
                              ref.read(taskProvider.notifier).toggleComplete(task.id);
                            },
                          );
                        } else {
                          HapticFeedback.lightImpact();
                        }
                        ref.read(taskProvider.notifier).toggleComplete(task.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: AnimatedScale(
                          scale: _isCheckboxPressed ? 0.85 : 1.0,
                          duration: const Duration(milliseconds: 140),
                          curve: Curves.easeOutCubic,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: task.isCompleted
                                  ? GlassTheme.accentSuccess
                                  : (_isCheckboxPressed
                                      ? GlassTheme.accentSuccess.withValues(alpha: 0.20)
                                      : Colors.transparent),
                              border: Border.all(
                                color: (task.isCompleted || _isCheckboxPressed)
                                    ? GlassTheme.accentSuccess
                                    : (isDark
                                        ? const Color(0xFF545458)
                                        : const Color(0xFFB0B0B6)),
                                width: 2.0,
                              ),
                            ),
                            child: AnimatedScale(
                              scale: task.isCompleted ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.elasticOut,
                              child: const Icon(
                                CupertinoIcons.checkmark,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Task Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? (task.isCompleted
                                            ? const Color(0xFF636366)
                                            : Colors.white)
                                        : (task.isCompleted
                                            ? const Color(0xFF8E8E93)
                                            : Colors.black),
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (category != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: catColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    category.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: catColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (task.note != null && task.note!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              task.note!,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? const Color(0xFF8E8E93)
                                    : const Color(0xFF8E8E93),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.clock,
                                size: 12,
                                color: const Color(0xFF8E8E93),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${DateFormat('hh:mm a').format(task.startTime)} – ${DateFormat('hh:mm a').format(task.endTime)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
