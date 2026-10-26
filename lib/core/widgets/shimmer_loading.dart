import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/glass_theme.dart';

class ShimmerGlass extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerGlass({
    super.key,
    this.width = double.infinity,
    this.height = 84,
    this.borderRadius = GlassTheme.radiusMedium,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE5E5EA);
    final highlightColor = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFFFFFFFF);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C1E)
            : Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark
              ? const Color(0xFF38383A)
              : const Color(0xFFD1D5DB).withValues(alpha: 0.8),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          period: const Duration(milliseconds: 1400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Skeleton avatar / icon circle
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 10,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A column of shimmer cards for loading states
class ShimmerGlassList extends StatelessWidget {
  final int count;

  const ShimmerGlassList({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: ShimmerGlass(),
        ),
      ),
    );
  }
}
