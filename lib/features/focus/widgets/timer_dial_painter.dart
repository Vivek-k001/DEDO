import 'dart:math' as math;
import 'package:flutter/material.dart';

class SquircleTickPainter extends CustomPainter {
  final double progress; // Overall focus session progress (0.0 to 1.0)
  final Color activeColor;
  final Color inactiveColor;
  final int tickCount; // 60 ticks for 60 seconds
  final int remainingSeconds;
  final int totalSeconds;
  final bool isDark;

  SquircleTickPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    this.tickCount = 60, // Exactly 60 ticks around the squircle perimeter
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final w = size.width;
    final h = size.height;
    
    // Inset from squircle border
    final inset = 11.0;

    // Active tick index based on total session progress (0.0 to 1.0)
    final clampedProgress = progress.clamp(0.0, 1.0);
    // Number of ticks lit up out of 60 based on full session progress
    final activeTickIndex = (clampedProgress * (tickCount - 1)).round();

    // 1. Draw 60 Perimeter Dial Ticks (proportional to total session duration)
    for (int i = 0; i < tickCount; i++) {
      // Angle starting from top (-pi / 2) going clockwise
      final angle = -math.pi / 2 + (2 * math.pi * i / tickCount);
      
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);

      final rx = (w / 2) - inset;
      final ry = (h / 2) - inset;

      // Superellipse radial approximation for continuous squircle
      final cosPow = math.pow(cosA.abs(), 3.5);
      final sinPow = math.pow(sinA.abs(), 3.5);
      final dist = math.pow(cosPow / math.pow(rx, 3.5) + sinPow / math.pow(ry, 3.5), -1.0 / 3.5).toDouble();

      // Major markers every 5 ticks
      final isMajor = i % 5 == 0;
      final tickLength = isMajor ? 7.5 : 4.5;

      final outer = Offset(center.dx + cosA * dist, center.dy + sinA * dist);
      final inner = Offset(center.dx + cosA * (dist - tickLength), center.dy + sinA * (dist - tickLength));

      // Active state: lit up up to current session progress
      final isActive = clampedProgress > 0 && i <= activeTickIndex;
      final isCurrent = i == activeTickIndex && clampedProgress > 0;

      final paint = Paint()
        ..color = isCurrent
            ? activeColor
            : (isActive
                ? activeColor.withValues(alpha: 0.85)
                : (isMajor
                    ? (isDark ? Colors.white38 : Colors.black38)
                    : inactiveColor))
        ..strokeWidth = isCurrent ? 2.5 : (isMajor ? 1.8 : 1.2)
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(inner, outer, paint);
    }

    // 2. SMALLER WHITE SECOND NEEDLE: Sweeps every second (0..59)
    // Elapsed seconds within the current minute
    final elapsedTotal = (totalSeconds - remainingSeconds).clamp(0, totalSeconds);
    final currentSecond = elapsedTotal % 60;
    final secondAngle = -math.pi / 2 + (2 * math.pi * currentSecond / 60);
    // Noticeably smaller and slim so the colored main needle is dominant
    final secondHandLength = (w / 2) * 0.38;

    final secondEnd = Offset(
      center.dx + math.cos(secondAngle) * secondHandLength,
      center.dy + math.sin(secondAngle) * secondHandLength,
    );
    final secondTail = Offset(
      center.dx - math.cos(secondAngle) * 5.0,
      center.dy - math.sin(secondAngle) * 5.0,
    );

    final whiteNeedlePaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.85)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(secondTail, secondEnd, whiteNeedlePaint);

    // 3. MAIN COLORED NEEDLE: Represents the total focus session progress (reaches 100% when time is up)
    final progressAngle = -math.pi / 2 + (2 * math.pi * clampedProgress);
    final mainHandLength = (w / 2) * 0.65;

    final mainHandEnd = Offset(
      center.dx + math.cos(progressAngle) * mainHandLength,
      center.dy + math.sin(progressAngle) * mainHandLength,
    );
    final mainHandTail = Offset(
      center.dx - math.cos(progressAngle) * 9.0,
      center.dy - math.sin(progressAngle) * 9.0,
    );

    final coloredNeedlePaint = Paint()
      ..color = activeColor
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(mainHandTail, mainHandEnd, coloredNeedlePaint);

    // 4. Center Pivot Cap (layers both needles cleanly)
    final outerPivot = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.2, outerPivot);

    final innerPivot = Paint()
      ..color = isDark ? const Color(0xFF1C1C1E) : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 1.8, innerPivot);
  }

  @override
  bool shouldRepaint(covariant SquircleTickPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.remainingSeconds != remainingSeconds ||
        oldDelegate.totalSeconds != totalSeconds ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.tickCount != tickCount ||
        oldDelegate.isDark != isDark;
  }
}
