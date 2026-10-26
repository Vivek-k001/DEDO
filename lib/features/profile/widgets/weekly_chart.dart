import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../core/widgets/glass_container.dart';

class WeeklyChart extends StatelessWidget {
  final List<int> data; // 7 values, Mon(0) to Sun(6)

  const WeeklyChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final currentWeekdayIndex = now.weekday - 1; // 0 for Mon, 6 for Sun

    // Fixed limit of 5 as requested
    const double maxY = 5.0;
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // 7 iOS signature colors for the 7 days of the week (Mon to Sun)
    const dayColors = [
      Color(0xFFFF5A52), // Mon: Soft Coral Red
      Color(0xFFFF9500), // Tue: Warm Tangerine Orange
      Color(0xFFFFCC00), // Wed: Soft Sunflower Yellow
      Color(0xFF34C759), // Thu: Apple Mint Green
      Color(0xFF30B0C7), // Fri: Cyan / Sky Blue
      Color(0xFF007AFF), // Sat: Apple Royal Blue
      Color(0xFFAF52DE), // Sun: Lilac Violet
    ];

    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF636366);

    return GlassContainer(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      borderRadius: GlassTheme.radiusLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Monday – Sunday performance',
                style: TextStyle(
                  fontSize: 12,
                  color: subtextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Bar Chart with clean in-bar numbers
          SizedBox(
            height: 155,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                groupsSpace: 10,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.transparent,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: -20, // Negative margin pulls the text down INSIDE the top of the bar
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final actualCount =
                          group.x < data.length ? data[group.x] : 0;
                      if (actualCount <= 5) return null;
                      return BarTooltipItem(
                        '$actualCount',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (val, meta) {
                        final i = val.toInt();
                        if (i < 0 || i >= days.length) {
                          return const SizedBox.shrink();
                        }
                        final isToday = i == currentWeekdayIndex;
                        final dayColor = dayColors[i];
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            days[i],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  isToday ? FontWeight.w800 : FontWeight.w600,
                              color: isToday ? dayColor : subtextColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (val, meta) {
                        final v = val.toInt();
                        if (v >= 0 && v <= 5 && val == v.toDouble()) {
                          return Text(
                            v.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: subtextColor.withValues(alpha: 0.7),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05),
                    strokeWidth: 0.8,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  7,
                  (i) {
                    final actualCount = i < data.length ? data[i] : 0;
                    // Cap the bar visual fill at maxY = 5
                    final displayY = actualCount.clamp(0, 5).toDouble();
                    final exceedsLimit = actualCount > 5;
                    final dayColor = dayColors[i];

                    return BarChartGroupData(
                      x: i,
                      showingTooltipIndicators: exceedsLimit ? [0] : const [],
                      barRods: [
                        BarChartRodData(
                          toY: displayY,
                          width: 22,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          gradient: displayY > 0
                              ? LinearGradient(
                                  colors: [
                                    dayColor.withValues(alpha: 0.75),
                                    dayColor,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                )
                              : null,
                          color: displayY == 0 ? Colors.transparent : null,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : Colors.black.withValues(alpha: 0.03),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
