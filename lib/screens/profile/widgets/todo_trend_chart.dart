import 'package:dedo/utils/constants/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DTodoTrendChart extends StatefulWidget {
  final List<double> weeklyData; // Data points for each day of the week
  final Color? lineColor; // Optional color for the chart line
  final Color? areaColor; // Optional color for the area below the line

  const DTodoTrendChart({
    super.key,
    required this.weeklyData,
    this.lineColor,
    this.areaColor,
  });

  @override
  State<DTodoTrendChart> createState() => _DTodoTrendChartState();
}

class _DTodoTrendChartState extends State<DTodoTrendChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController; // Controls the chart animation
  late Animation<double> _animation; // Animation value from 0 to 1
  int?
  _touchedIndex; // Currently touched index on the chart for tooltip/highlight

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for 1.5 seconds animation duration
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    // Define animation curve from 0 to 1
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    // Start animation immediately on widget load
    _animationController.forward();
  }

  @override
  void dispose() {
    // Dispose animation controller to free resources
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DTodoTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If weekly data changes, restart animation
    if (oldWidget.weeklyData != widget.weeklyData) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no data or all zeros, show empty state widget
    if (widget.weeklyData.isEmpty || widget.weeklyData.every((e) => e == 0)) {
      return _buildEmptyState();
    }

    // Animated builder to rebuild chart as animation progresses
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            SizedBox(
              height: 200,
              child: LineChart(
                _buildChartData(), // Chart configuration
                duration: const Duration(milliseconds: 250), // Refresh duration
              ),
            ),
            const SizedBox(height: 16),
            _buildWeekdayLegend(), // Weekday labels below the chart
          ],
        );
      },
    );
  }

  // Widget shown when there is no data to display
  Widget _buildEmptyState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated scaling icon
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    Icons.insights,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'No completion data this week',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete some tasks to see your progress!',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Builds the chart data and style configuration
  LineChartData _buildChartData() {
    // Determine max y-value from weekly data
    final maxY = widget.weeklyData.reduce((a, b) => a > b ? a : b);
    // Add 20% padding above max for better visual spacing
    final adjustedMaxY = maxY > 0 ? maxY + (maxY * 0.2) : 5.0;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY > 0 ? maxY / 4 : 1,
        getDrawingHorizontalLine: (value) {
          // Dashed horizontal grid lines
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
            dashArray: [4, 4],
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false), // No right titles
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false), // No top titles
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
              final intValue = value.toInt();

              if (value == intValue &&
                  intValue >= 1 &&
                  intValue <= days.length) {
                final index = intValue - 1;
                final isToday = _isToday(index);
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration:
                        isToday
                            ? BoxDecoration(
                              color: widget.lineColor ?? DColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            )
                            : null,
                    child: Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),

        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            interval: maxY > 0 ? (maxY / 4).ceilToDouble() : 1,
            getTitlesWidget: (value, meta) {
              // Show y-axis labels except for zero and greater than highest value
              if (value == 0 || value > maxY) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
      ),
      minX: 1,
      maxX: widget.weeklyData.length.toDouble(),
      minY: 0,
      maxY: adjustedMaxY,
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          setState(() {
            // Update touched index for showing tooltip and highlight
            if (touchResponse?.lineBarSpots?.isNotEmpty == true) {
              _touchedIndex = touchResponse!.lineBarSpots!.first.spotIndex;
            } else {
              _touchedIndex = null;
            }
          });
        },
        getTouchedSpotIndicator: (
          LineChartBarData barData,
          List<int> spotIndexes,
        ) {
          // Customize touched spot appearance: dashed vertical line + circle dot
          return spotIndexes.map((spotIndex) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: widget.lineColor ?? DColors.primary,
                strokeWidth: 2,
                dashArray: [4, 4],
              ),
              FlDotData(
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: Colors.white,
                    strokeWidth: 3,
                    strokeColor: widget.lineColor ?? DColors.primary,
                  );
                },
              ),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor:
              (touchedSpot) =>
                  (widget.lineColor ?? DColors.primary).withValues(alpha: 0.9),
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            // Tooltip content for touched spots
            return touchedBarSpots.map((barSpot) {
              final dayNames = [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday',
              ];
              final dayIndex = barSpot.x.toInt() - 1;
              final dayName =
                  dayIndex >= 0 && dayIndex < dayNames.length
                      ? dayNames[dayIndex]
                      : 'Day ${dayIndex + 1}';

              return LineTooltipItem(
                '$dayName\n${barSpot.y.toInt()} tasks',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          // Data points animated by current animation value (smooth grow)
          spots:
              widget.weeklyData.asMap().entries.map((e) {
                final animatedValue = e.value * _animation.value;
                return FlSpot(e.key.toDouble() + 1, animatedValue);
              }).toList(),
          isCurved: true,
          preventCurveOverShooting: true,
          curveSmoothness: 0.35,
          color: widget.lineColor ?? DColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(
            show: true,
            // Gradient fill under line from semi-transparent to fully transparent
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                (widget.areaColor ?? widget.lineColor ?? DColors.primary)
                    .withValues(alpha: 0.3),
                (widget.areaColor ?? widget.lineColor ?? DColors.primary)
                    .withValues(alpha: 0.0),
              ],
            ),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final isHighlighted = _touchedIndex == index;
              // Bigger white dot with border for highlighted, smaller for others
              return FlDotCirclePainter(
                radius: isHighlighted ? 5 : 3,
                color:
                    isHighlighted
                        ? Colors.white
                        : widget.lineColor ?? DColors.primary,
                strokeWidth: isHighlighted ? 2 : 0,
                strokeColor: widget.lineColor ?? DColors.primary,
              );
            },
          ),
        ),
      ],
    );
  }

  // Builds the weekday legend below the chart with tap interaction
  Widget _buildWeekdayLegend() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now().weekday - 1; // 0 = Monday

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          days.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final isToday = index == today;
            final value =
                index < widget.weeklyData.length
                    ? widget.weeklyData[index]
                    : 0.0;

            return GestureDetector(
              onTap: () {
                setState(() {
                  // Toggle highlight on tap
                  _touchedIndex = _touchedIndex == index ? null : index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // Highlight today's background with low opacity color
                  color:
                      isToday
                          ? (widget.lineColor ?? DColors.primary).withValues(
                            alpha: 0.1,
                          )
                          : null,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      _touchedIndex == index
                          ? Border.all(
                            color: widget.lineColor ?? DColors.primary,
                          )
                          : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                        color:
                            isToday
                                ? widget.lineColor ?? DColors.primary
                                : Colors.grey[600],
                      ),
                    ),
                    Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            value > 0
                                ? widget.lineColor ?? DColors.primary
                                : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  // Helper to check if given day index corresponds to today
  bool _isToday(int dayIndex) {
    final today = DateTime.now().weekday - 1; // 0 = Monday
    return dayIndex == today;
  }
}
