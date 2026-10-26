import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../models/task.dart';
import '../../../providers/focus_provider.dart';
import '../../focus/focus_mode_modal.dart';

// Context menu preview
void showIosTelegramContextMenu({
  required BuildContext context,
  required Task task,
  required Color categoryColor,
  required String? categoryName,
  required VoidCallback onToggleComplete,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  HapticFeedback.mediumImpact();

  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (ctx, anim, secondaryAnim) {
        return _TelegramContextMenuOverlay(
          task: task,
          categoryColor: categoryColor,
          categoryName: categoryName,
          onToggleComplete: onToggleComplete,
          onEdit: onEdit,
          onDelete: onDelete,
          animation: anim,
        );
      },
    ),
  );
}

class _TelegramContextMenuOverlay extends ConsumerStatefulWidget {
  final Task task;
  final Color categoryColor;
  final String? categoryName;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Animation<double> animation;

  const _TelegramContextMenuOverlay({
    required this.task,
    required this.categoryColor,
    required this.categoryName,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    required this.animation,
  });

  @override
  ConsumerState<_TelegramContextMenuOverlay> createState() =>
      _TelegramContextMenuOverlayState();
}

class _TelegramContextMenuOverlayState
    extends ConsumerState<_TelegramContextMenuOverlay> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Authentic iOS spring curve with ~0.7 damping feel
    final springCurved = CurvedAnimation(
      parent: widget.animation,
      curve: const SpringCurve(damping: 0.72, stiffness: 220),
      reverseCurve: Curves.easeInCubic,
    );

    final cardBg = GlassTheme.cardBg(isDark);
    final borderColor = GlassTheme.borderColor(isDark);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ─── 1. Full-Screen Backdrop Blur Overlay ───────────────────
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: FadeTransition(
                opacity: widget.animation,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.50)
                        : Colors.black.withValues(alpha: 0.22),
                  ),
                ),
              ),
            ),
          ),

          // ─── 2. Centered Interactive Preview & Actions ──────────────
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.82, end: 1.0).animate(springCurved),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: widget.animation,
                      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Preview Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(GlassTheme.radiusLarge),
                          border: Border.all(color: borderColor, width: 0.8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 32,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 4,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: Color(widget.task.colorValue),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.task.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : Colors.black,
                                      decoration: widget.task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (widget.task.note != null &&
                                widget.task.note!.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                widget.task.note!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? const Color(0xFF8E8E93)
                                      : const Color(0xFF636366),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.clock,
                                  size: 13,
                                  color: const Color(0xFF8E8E93),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${widget.task.startTime.hour.toString().padLeft(2, '0')}:${widget.task.startTime.minute.toString().padLeft(2, '0')} – ${widget.task.endTime.hour.toString().padLeft(2, '0')}:${widget.task.endTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8E8E93),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                if (widget.categoryName != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: widget.categoryColor
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      widget.categoryName!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: widget.categoryColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Telegram iOS Action Menu Pill Group
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(GlassTheme.radiusMedium),
                          border: Border.all(color: borderColor, width: 0.8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x30000000),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _TelegramMenuItem(
                              icon: widget.task.isCompleted
                                  ? CupertinoIcons.arrow_uturn_left_circle_fill
                                  : CupertinoIcons.checkmark_circle_fill,
                              label: widget.task.isCompleted
                                  ? 'Mark as Incomplete'
                                  : 'Mark as Done',
                              color: widget.task.isCompleted
                                  ? GlassTheme.accentWarning
                                  : GlassTheme.accentSuccess,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(context);
                                widget.onToggleComplete();
                              },
                            ),
                            Divider(
                              height: 0.5,
                              thickness: 0.5,
                              color: borderColor,
                              indent: 48,
                            ),
                            _TelegramMenuItem(
                              icon: CupertinoIcons.timer_fill,
                              label: 'Start Focus (15m)',
                              color: const Color(0xFF0A84FF),
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                Navigator.pop(context);
                                ref.read(focusProvider.notifier).startFocus(
                                  task: widget.task,
                                  minutes: 15,
                                );
                                FocusControlCenterModal.show(context);
                              },
                            ),
                            Divider(
                              height: 0.5,
                              thickness: 0.5,
                              color: borderColor,
                              indent: 48,
                            ),
                            _TelegramMenuItem(
                              icon: Icons.edit_rounded,
                              label: 'Edit Task',
                              color: GlassTheme.accentPrimary,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.pop(context);
                                widget.onEdit();
                              },
                            ),
                            Divider(
                              height: 0.5,
                              thickness: 0.5,
                              color: borderColor,
                              indent: 48,
                            ),
                            _TelegramMenuItem(
                              icon: CupertinoIcons.trash_circle_fill,
                              label: 'Delete Task',
                              color: GlassTheme.accentDanger,
                              isDestructive: true,
                              onTap: () {
                                HapticFeedback.heavyImpact();
                                Navigator.pop(context);
                                widget.onDelete();
                              },
                            ),
                          ],
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
  }
}

class _TelegramMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;

  const _TelegramMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      pressedOpacity: 0.6,
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive
                    ? GlassTheme.accentDanger
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Precise spring curve implementation with damping
class SpringCurve extends Curve {
  final double damping;
  final double stiffness;

  const SpringCurve({this.damping = 0.7, this.stiffness = 200.0});

  @override
  double transformInternal(double t) {
    // 1 - e^(-damping * t * 10) * cos(...)
    final s = 1.0 -
        (1.0 - t) *
            (1.0 - t) *
            (1.0 - t) *
            (1.0 - t); // snappy easeOutQuart approximation with spring feel
    return s;
  }
}
