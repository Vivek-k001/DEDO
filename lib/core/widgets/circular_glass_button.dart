import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// iOS Liquid Glass Circular Action Button
///
/// Implements Apple's signature Liquid Glass optics from the Sticky Note X button:
/// 1. Physical depth drop shadows (ambient 14px + elevation contact 4px)
/// 2. Radial refractive glass body with BackdropFilter blur 18 and directional gradient
/// 3. Directional 315° rim light sweep gradient with specular crescent and bottom bounce
/// 4. Specular shadow-glow icon glyph
/// 5. Physical spring scale press interaction (0.86) and haptics
class CircularGlassButton extends StatefulWidget {
  final double size;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final String? badgeText;
  final Color? glowColor;
  final Widget? child;
  final bool isDark;
  final VoidCallback onTap;

  const CircularGlassButton({
    super.key,
    this.size = 44.0,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.badgeText,
    this.glowColor,
    this.child,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<CircularGlassButton> createState() => _CircularGlassButtonState();
}

class _CircularGlassButtonState extends State<CircularGlassButton>
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
    final effectiveIconSize = widget.iconSize ?? (size * 0.46);
    final effectiveIconColor = widget.iconColor ??
        (isDark ? Colors.white.withValues(alpha: 0.98) : const Color(0xFF111111));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.86 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // ── Layer 1: Depth shadow (physical elevation) ──
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.glowColor ??
                          (isDark
                              ? Colors.black.withValues(alpha: 0.45)
                              : Colors.black.withValues(alpha: 0.16)),
                      blurRadius: size > 50 ? 16 : 14,
                      offset: Offset(0, size > 50 ? 5 : 4),
                    ),
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.22)
                          : Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),

              // ── Layer 2: Glass base with circular refractive body & blur 18 ──
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.25, -0.35),
                        radius: 0.95,
                        colors: isDark
                            ? [
                                Colors.white.withValues(alpha: 0.18),
                                Colors.white.withValues(alpha: 0.05),
                                Colors.black.withValues(alpha: 0.28),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.92),
                                Colors.white.withValues(alpha: 0.55),
                                Colors.white.withValues(alpha: 0.32),
                              ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Layer 3: Circular Rim Light ──
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: CircularGlassRimPainter(isDark: isDark),
                  ),
                ),
              ),

              // ── Layer 4: Icon or Child (bold glyph with specular depth) ──
              if (widget.icon != null)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      size: effectiveIconSize,
                      color: effectiveIconColor,
                      shadows: [
                        Shadow(
                          color: widget.iconColor != null
                              ? widget.iconColor!.withValues(alpha: 0.5)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : Colors.black.withValues(alpha: 0.7)),
                          blurRadius: 1.2,
                        ),
                        Shadow(
                          color: widget.iconColor != null
                              ? widget.iconColor!.withValues(alpha: 0.3)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : Colors.black.withValues(alpha: 0.5)),
                          blurRadius: 0.6,
                        ),
                      ],
                    ),
                    Icon(
                      widget.icon,
                      size: effectiveIconSize,
                      color: effectiveIconColor,
                    ),
                  ],
                )
              else if (widget.child != null)
                widget.child!,

              // ── Optional: Mini Status Badge (e.g. Focus Timer) ──
              if (widget.badgeText != null)
                Positioned(
                  top: -3,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A84FF),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0A84FF).withValues(alpha: 0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.badgeText!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
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

/// iOS Liquid Glass Pill / Stadium Action Button
///
/// Implements the exact same multi-layer Liquid Glass optical recipe as the
/// signature circular action button, but configured for stadium / pill buttons:
/// - Layer 1: Ambient elevation & contact shadows
/// - Layer 2: Stadium refractive glass body with BackdropFilter blur 18 and radial gradient
/// - Layer 3: Continuous 315° specular rim light contour
/// - Layer 4: Bold content row (icon + label)
/// - Snappy press scale interaction (0.92) with haptics
class LiquidGlassPillButton extends StatefulWidget {
  final Widget child;
  final bool isDark;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? glowColor;
  final bool isSelected;
  final Color? selectedColor;

  const LiquidGlassPillButton({
    super.key,
    required this.child,
    required this.isDark,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.borderRadius = 20.0,
    this.glowColor,
    this.isSelected = false,
    this.selectedColor,
  });

  @override
  State<LiquidGlassPillButton> createState() => _LiquidGlassPillButtonState();
}

class _LiquidGlassPillButtonState extends State<LiquidGlassPillButton>
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
    final isSelected = widget.isSelected;
    final accent = widget.selectedColor ?? const Color(0xFF0A84FF);
    final rrect = BorderRadius.circular(widget.borderRadius);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: rrect,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor ??
                    (isDark
                        ? Colors.black.withValues(alpha: 0.40)
                        : Colors.black.withValues(alpha: 0.14)),
                blurRadius: 12,
                offset: const Offset(0, 3.5),
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.20)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: rrect,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Stack(
                children: [
                  // ── Layer 2: Stadium Refractive Glass Body ──
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: rrect,
                        gradient: RadialGradient(
                          center: const Alignment(-0.25, -0.35),
                          radius: 1.2,
                          colors: isSelected
                              ? (isDark
                                  ? [
                                      accent.withValues(alpha: 0.50),
                                      accent.withValues(alpha: 0.25),
                                      Colors.black.withValues(alpha: 0.30),
                                    ]
                                  : [
                                      accent.withValues(alpha: 0.35),
                                      accent.withValues(alpha: 0.18),
                                      Colors.white.withValues(alpha: 0.65),
                                    ])
                              : (isDark
                                  ? [
                                      Colors.white.withValues(alpha: 0.22),
                                      Colors.white.withValues(alpha: 0.08),
                                      Colors.black.withValues(alpha: 0.22),
                                    ]
                                  : [
                                      Colors.white.withValues(alpha: 0.94),
                                      Colors.white.withValues(alpha: 0.60),
                                      Colors.white.withValues(alpha: 0.38),
                                    ]),
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // ── Layer 3: Pill Specular Rim Light ──
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: PillGlassRimPainter(
                          isDark: isDark,
                          borderRadius: widget.borderRadius,
                        ),
                      ),
                    ),
                  ),

                  // ── Layer 4: Content ──
                  Padding(
                    padding: widget.padding,
                    child: widget.child,
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

/// Circular Liquid Glass Rim Painter
///
/// Accurately renders circular rim lighting, top-left specular illumination,
/// and bottom bounce reflection based on Apple's Liquid Glass optics.
class CircularGlassRimPainter extends CustomPainter {
  final bool isDark;

  const CircularGlassRimPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 1.2) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Full perimeter baseline outline (delicate glass contour)
    final baseOutlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.14)
          : Colors.white.withValues(alpha: 0.45);
    canvas.drawCircle(center, radius, baseOutlinePaint);

    // 2. Dynamic SweepGradient Rim Light
    final rimLightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width > 50 ? 1.3 : 1.1
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: math.pi * 2,
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.08), // Right (shadowed edge)
                Colors.white.withValues(alpha: 0.32), // Bottom (ambient bounce)
                Colors.white.withValues(alpha: 0.10), // Bottom-left transition
                Colors.white.withValues(alpha: 0.85), // Top-left (bright specular rim)
                Colors.white.withValues(alpha: 0.50), // Top transition
                Colors.white.withValues(alpha: 0.08), // Right (shadowed edge)
              ]
            : [
                Colors.white.withValues(alpha: 0.25),
                Colors.white.withValues(alpha: 0.60),
                Colors.white.withValues(alpha: 0.30),
                Colors.white.withValues(alpha: 0.98),
                Colors.white.withValues(alpha: 0.70),
                Colors.white.withValues(alpha: 0.25),
              ],
        stops: const [0.0, 0.25, 0.45, 0.68, 0.85, 1.0],
      ).createShader(rect);

    canvas.drawCircle(center, radius, rimLightPaint);
  }

  @override
  bool shouldRepaint(covariant CircularGlassRimPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

/// Pill / Stadium Specular Glass Rim Painter
class PillGlassRimPainter extends CustomPainter {
  final bool isDark;
  final double borderRadius;

  const PillGlassRimPainter({
    required this.isDark,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.5, 0.5, size.width - 1.0, size.height - 1.0);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius - 0.5));

    // 1. Baseline contour outline
    final baseOutlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.14)
          : Colors.white.withValues(alpha: 0.45);
    canvas.drawRRect(rrect, baseOutlinePaint);

    // 2. Continuous 315° specular rim light
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..shader = LinearGradient(
        begin: const Alignment(-0.8, -1.0),
        end: const Alignment(0.8, 1.0),
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.88), // Lit top-left
                Colors.white.withValues(alpha: 0.48), // Top
                Colors.white.withValues(alpha: 0.10), // Right
                Colors.white.withValues(alpha: 0.38), // Bottom bounce
              ]
            : [
                Colors.white.withValues(alpha: 0.98), // Lit top-left
                Colors.white.withValues(alpha: 0.75), // Top
                Colors.white.withValues(alpha: 0.22), // Right
                Colors.white.withValues(alpha: 0.65), // Bottom bounce
              ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, rimPaint);
  }

  @override
  bool shouldRepaint(covariant PillGlassRimPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.borderRadius != borderRadius;
  }
}
