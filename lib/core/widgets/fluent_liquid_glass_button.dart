import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Apple Liquid Glass Button (Canonical iOS Specification)
///
/// Implements "The One Rule":
/// "Glass goes on an empty layer BEHIND the content - never on the frame that holds the icons.
///  A frame with glass refracts its own children, which warps the artwork."
///
/// Specification Tokens:
/// - blur: 6
/// - depth: 80 / 16
/// - refraction: 0.6 - 0.8
/// - light: 0.7 @ 315° (top-left light incidence)
/// - drop shadow: blur 28-32, black 18-20%
/// - content: pure, undistorted glyph above the glass
class FluentLiquidGlassButton extends StatefulWidget {
  final double size;
  final bool isDark;
  final VoidCallback onTap;
  final IconData icon;

  const FluentLiquidGlassButton({
    super.key,
    this.size = 62.0,
    required this.isDark,
    required this.onTap,
    this.icon = CupertinoIcons.plus,
  });

  @override
  State<FluentLiquidGlassButton> createState() => _FluentLiquidGlassButtonState();
}

class _FluentLiquidGlassButtonState extends State<FluentLiquidGlassButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final size = widget.size;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Layer 1: Ambient Drop Shadow (spec: drop shadow 30-40, black 18-20%) ──
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.18),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),

              // ── Layer 2: EMPTY GLASS LAYER (The One Rule: Glass goes BEHIND content) ──
              // Spec: blur 6, subtle tint so background colors/content shine through with pure liquid clarity
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), // Canonical spec: blur 6
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.20),
                    ),
                  ),
                ),
              ),

              // ── Layer 3: Directional Specular Rim (Spec: light 0.7 @ 315°) ──
              // Razor-sharp 1.0px rim lit at 315° (top-left) with subtle ambient bounce
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _AppleLiquidGlassRimPainter(isDark: isDark),
                  ),
                ),
              ),

              // ── Layer 4: ICONS & LABELS (Above the glass, undistorted) ──
              // Bold, pure glyph sitting above the glass layer
              Icon(
                widget.icon,
                size: size * 0.46, // ~28.5px for 62px button
                color: isDark ? Colors.white : const Color(0xFF111111),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Directional Specular Rim Painter
///
/// Implements: light 0.7 @ 315°
/// Polar angle 315° = top-left (7*pi/4).
class _AppleLiquidGlassRimPainter extends CustomPainter {
  final bool isDark;

  const _AppleLiquidGlassRimPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 1.0) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Delicate perimeter baseline contour
    final baseOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.35);
    canvas.drawCircle(center, radius, baseOutline);

    // 2. Light 0.7 @ 315° (Top-Left Highlight Apex)
    // SweepGradient with peak intensity at 315° (7*pi/4 ≈ 5.498 rad)
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: math.pi * 2,
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.08), // Right (0°)
                Colors.white.withValues(alpha: 0.28), // Bottom-Right / Bottom bounce
                Colors.white.withValues(alpha: 0.12), // Bottom-Left
                Colors.white.withValues(alpha: 0.70), // Top-Left (315° light apex)
                Colors.white.withValues(alpha: 0.45), // Top
                Colors.white.withValues(alpha: 0.08), // Right (360°)
              ]
            : [
                Colors.white.withValues(alpha: 0.20), // Right (0°)
                Colors.white.withValues(alpha: 0.50), // Bottom bounce
                Colors.white.withValues(alpha: 0.25), // Bottom-Left
                Colors.white.withValues(alpha: 0.85), // Top-Left (315° light apex)
                Colors.white.withValues(alpha: 0.60), // Top
                Colors.white.withValues(alpha: 0.20), // Right (360°)
              ],
        stops: const [0.0, 0.25, 0.50, 0.82, 0.92, 1.0],
      ).createShader(rect);

    canvas.drawCircle(center, radius, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _AppleLiquidGlassRimPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
