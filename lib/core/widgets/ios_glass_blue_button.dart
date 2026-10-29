import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// iOS Glass Blue Button
///
/// Implements authentic Apple iOS liquid glass aesthetics for primary buttons:
/// - Canonical iOS System Blue fill (light: #007AFF -> #0062E0, dark: #0A84FF -> #0071E3)
/// - Directional 315° specular glass rim outline (white glass outline with peak apex reflection)
/// - Top inner curvature glass sheen (simulates light reflecting through curved crystal bezel)
/// - Dual-layer depth shadow (ambient blue glow + subtle dark contact shadow)
/// - Snappy press-scale interaction (0.94) with iOS haptic feedback
class IosGlassBlueButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isDark;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? blueColor;
  final double? width;
  final double? height;
  final bool isLoading;

  const IosGlassBlueButton({
    super.key,
    required this.child,
    required this.onTap,
    required this.isDark,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.blueColor,
    this.width,
    this.height,
    this.isLoading = false,
  });

  @override
  State<IosGlassBlueButton> createState() => _IosGlassBlueButtonState();
}

class _IosGlassBlueButtonState extends State<IosGlassBlueButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    if (!widget.isLoading) {
      widget.onTap();
    }
  }

  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final rrect = BorderRadius.circular(widget.borderRadius);

    // Canonical iOS system blue gradient
    final baseColor = widget.blueColor ??
        (isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF));
    final endColor = isDark ? const Color(0xFF0071E3) : const Color(0xFF0062E0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: rrect,
            boxShadow: [
              // Ambient blue glass glow
              BoxShadow(
                color: baseColor.withValues(alpha: isDark ? 0.45 : 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
              // Soft contact depth shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                blurRadius: 4,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: rrect,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ── Layer 1: Vibrant iOS System Blue Fill ──
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: rrect,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            baseColor,
                            endColor,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Layer 2: Top Bevel Glass Sheen Reflection ──
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 24,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(widget.borderRadius),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.32),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Layer 3: Directional White Glass Specular Rim Outline ──
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _IosBlueGlassRimPainter(
                          isDark: isDark,
                          borderRadius: widget.borderRadius,
                        ),
                      ),
                    ),
                  ),

                  // ── Layer 4: Button Content ──
                  Padding(
                    padding: widget.padding,
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : widget.child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Directional Specular Glass Rim Outline Painter
///
/// Refers to Apple's canonical Liquid Glass edge optics:
/// - 315° top-left incident light highlight apex
/// - High-opacity frosted white contour
/// - Ambient bounce reflection on bottom edge
class _IosBlueGlassRimPainter extends CustomPainter {
  final bool isDark;
  final double borderRadius;

  const _IosBlueGlassRimPainter({
    required this.isDark,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Rect.fromLTWH(0.6, 0.6, size.width - 1.2, size.height - 1.2);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(math.max(0, borderRadius - 0.6)),
    );

    // 1. Full perimeter delicate glass contour
    final baseOutlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = Colors.white.withValues(alpha: isDark ? 0.35 : 0.45);
    canvas.drawRRect(rrect, baseOutlinePaint);

    // 2. Directional 315° specular white highlight rim
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..shader = LinearGradient(
        begin: const Alignment(-0.85, -1.0),
        end: const Alignment(0.85, 1.0),
        colors: [
          Colors.white.withValues(alpha: 0.95), // Apex highlight at top-left
          Colors.white.withValues(alpha: 0.70), // Top edge
          Colors.white.withValues(alpha: 0.20), // Right edge
          Colors.white.withValues(alpha: 0.55), // Bottom bounce reflection
        ],
        stops: const [0.0, 0.32, 0.70, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _IosBlueGlassRimPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.borderRadius != borderRadius;
  }
}
