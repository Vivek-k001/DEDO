import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../models/task.dart';
import '../../../providers/task_provider.dart';

void showTaskModal(BuildContext context, WidgetRef ref, Task task,
    {required VoidCallback onEdit}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Task Modal',
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) => _TaskModal(task: task, onEdit: onEdit),
    transitionBuilder: (ctx, anim, _, child) {
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
  );
}

class _TaskModal extends ConsumerWidget {
  final Task task;
  final VoidCallback onEdit;

  const _TaskModal({required this.task, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassContainer(
            borderRadius: GlassTheme.radiusLarge,
            padding: const EdgeInsets.all(28),
            fillOpacity: isDark ? 0.18 : 0.22,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A0A2E),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(8),
                          borderRadius: GlassTheme.radiusMedium,
                          showBorder: false,
                          child: Icon(
                            Icons.close_rounded,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.7)
                                : Colors.black.withValues(alpha: 0.5),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (task.note != null && task.note!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      task.note!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.55)
                            : Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Divider(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.08),
                  ),
                  const SizedBox(height: 20),
                  // Action buttons
                  _ActionButton(
                    icon: task.isCompleted
                        ? Icons.undo_rounded
                        : Icons.check_circle_rounded,
                    label: task.isCompleted
                        ? 'Mark as Pending'
                        : 'Mark as Completed',
                    color: GlassTheme.accentSuccess,
                    onTap: () {
                      ref.read(taskProvider.notifier).toggleComplete(task.id);
                      Navigator.pop(context);
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    icon: Icons.edit_rounded,
                    label: 'Edit Task',
                    color: GlassTheme.accentSecondary,
                    onTap: () {
                      Navigator.pop(context);
                      onEdit();
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    icon: Icons.delete_rounded,
                    label: 'Delete Task',
                    color: GlassTheme.accentDanger,
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDelete(context, ref, task.id);
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String taskId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Confirm',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: GlassContainer(
              borderRadius: GlassTheme.radiusLarge,
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_forever_rounded,
                      color: GlassTheme.accentDanger, size: 44),
                  const SizedBox(height: 16),
                  Text(
                    'Delete Task?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color:
                          isDark ? Colors.white : const Color(0xFF1A0A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: 'Cancel',
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.2)
                              : const Color(0xFF7C7C99),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassButton(
                          label: 'Delete',
                          color: GlassTheme.accentDanger,
                          onPressed: () {
                            ref
                                .read(taskProvider.notifier)
                                .deleteTask(taskId);
                            Navigator.pop(context);
                          },
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
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        borderRadius: GlassTheme.radiusMedium,
        tintColor: color,
        fillOpacity: 0.12,
        showBorder: true,
        borderOpacity: 0.25,
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
