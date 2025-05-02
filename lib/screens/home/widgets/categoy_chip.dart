import 'package:dedo/models/category_model.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/widgets/container.dart';
import 'package:flutter/material.dart';

class DCategoryChip extends StatelessWidget {
  final CategoryModel category;
  final int taskCount;
  final VoidCallback? onTap;

  const DCategoryChip({
    super.key,
    required this.category,
    required this.taskCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DContainer(
        margin: const EdgeInsets.only(left: DSizes.xs, right: DSizes.sm),
        padding: const EdgeInsets.all(12),
        backgroundColor: Color(category.color),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$taskCount tasks',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: DSizes.xs),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
