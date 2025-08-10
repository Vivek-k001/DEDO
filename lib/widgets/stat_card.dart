import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/widgets/container.dart';
import 'package:flutter/material.dart';

/// A card widget showing a statistic with an icon, title, value, and optional subtitle.
class StatCard extends StatelessWidget {
  final String title;     // Title text describing the stat
  final int value;        // Numeric value of the stat
  final IconData icon;    // Icon representing the stat visually
  final Color color;      // Primary color for icon and value text
  final String? subtitle; // Optional subtitle text

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return DContainer(
      padding: const EdgeInsets.all(DSizes.sm), // Outer padding of the card
      child: Column(
        mainAxisSize: MainAxisSize.min, // Wrap content vertically
        children: [
          // Circular icon container with light background tint of the color
          DContainer(
            padding: const EdgeInsets.all(DSizes.sm),
            backgroundColor: color.withAlpha(25), // Slightly transparent background
            shape: BoxShape.circle,
            child: Icon(icon, color: color, size: 24),
          ),

          const SizedBox(height: DSizes.sm),

          // Value text with bold style and main color
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),

          const SizedBox(height: DSizes.xs),

          // Title text with medium font weight, centered
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),

          // If subtitle is provided, show it with smaller grey text
          if (subtitle != null) ...[
            const SizedBox(height: DSizes.xs),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
