import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../core/widgets/glass_container.dart';

class DateStrip extends StatefulWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;
  final Map<String, int> taskCountMap; // Key: 'yyyy-MM-dd', Value: count

  const DateStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.taskCountMap = const {},
  });

  @override
  State<DateStrip> createState() => DateStripState();
}

class DateStripState extends State<DateStrip> {
  late final ScrollController _scroll;
  late final List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    final now = DateTime.now();
    _dates = List.generate(45, (i) => now.subtract(Duration(days: 10 - i)));
    // Scroll to today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToToday(animated: false);
    });
  }

  void scrollToToday({bool animated = true}) {
    final now = DateTime.now();
    scrollToDate(now, animated: animated);
  }

  void scrollToDate(DateTime target, {bool animated = true}) {
    final index = _dates.indexWhere((d) => _isSameDay(d, target));
    if (index != -1 && _scroll.hasClients) {
      // 54 (width) + 10 (spacing) = 64px per item
      final targetOffset = (index * 64.0) - 20;
      final clampedOffset =
          targetOffset.clamp(0.0, _scroll.position.maxScrollExtent);
      if (animated) {
        _scroll.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scroll.jumpTo(clampedOffset);
      }
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) => _isSameDay(d, DateTime.now());

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 94,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
        itemCount: _dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final date = _dates[i];
          final isSelected = _isSameDay(date, widget.selectedDate);
          final isToday = _isToday(date);
          final taskCount = widget.taskCountMap[_dateKey(date)] ?? 0;
          final showBadge = !isToday && taskCount > 0;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onDateSelected(date);
            },
            child: SizedBox(
              width: 54,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: 54,
                    height: 84,
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      borderRadius: GlassTheme.radiusMedium,
                      fillOpacity: isSelected
                          ? (isDark ? 0.9 : 1.0)
                          : (isDark ? 0.12 : 0.08),
                      tintColor: isSelected ? Theme.of(context).primaryColor : null,
                      shadows: null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE').format(date).toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : isDark
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : Colors.black.withValues(alpha: 0.45),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : isDark
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : Colors.black.withValues(alpha: 0.8),
                            ),
                          ),
                          if (isToday && !isSelected)
                            Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.only(top: 3),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ─── Top Floating Blue Task Count Badge ────────────────────
                  if (showBadge)
                    Positioned(
                      top: -4,
                      right: -3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF007AFF)
                                  .withValues(alpha: 0.45),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '$taskCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
