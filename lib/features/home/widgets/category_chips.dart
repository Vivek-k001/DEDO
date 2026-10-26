import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../models/category.dart';
import '../../../providers/task_provider.dart';

class CategoryChips extends ConsumerWidget {
  final String? selected;
  final void Function(String?) onSelected;
  final List<Category> categories;

  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.categories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasks = ref.watch(taskProvider);

    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: [
          // "All" chip
          _Chip(
            label: 'All',
            color: GlassTheme.accentPrimary,
            isSelected: selected == null,
            count: tasks.length,
            onTap: () => onSelected(null),
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          ...categories.map((cat) {
            final count = tasks.where((t) => t.categoryId == cat.id).length;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _Chip(
                label: cat.name,
                color: Color(cat.colorValue),
                isSelected: selected == cat.id,
                count: count,
                onTap: () => onSelected(selected == cat.id ? null : cat.id),
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;
  final bool isDark;

  const _Chip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.count,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: GlassTheme.radiusLarge,
          tintColor: isSelected ? color : null,
          fillOpacity: isSelected ? (isDark ? 0.85 : 0.95) : (isDark ? 0.12 : 0.08),
          shadows: null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.white.withValues(alpha: 0.75)
                          : Colors.black.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
