import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';

class GlassSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const GlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<GlassSwitch> createState() => _GlassSwitchState();
}

class _GlassSwitchState extends State<GlassSwitch> {
  bool _isPressed = false;
  bool _isDragging = false;
  double? _dragOffset;
  
  // Optimistic UI state to prevent rubber-banding glitch waiting for Riverpod to update!
  bool? _optimisticValue;

  @override
  void didUpdateWidget(GlassSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _optimisticValue = null;
    }
  }

  bool get _effectiveValue => _optimisticValue ?? widget.value;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    final newValue = !_effectiveValue;
    setState(() {
      _isPressed = false;
      _optimisticValue = newValue;
    });
    widget.onChanged(newValue);
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
      _isDragging = false;
      _dragOffset = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dimensions
    const double trackWidth = 64.0;
    const double trackHeight = 26.0;
    const double baseKnobWidth = 42.0;
    const double knobHeight = 32.0;

    final double maxLeft = trackWidth - baseKnobWidth + 4; // Right limit
    final double minLeft = -4.0; // Left limit

    final Color activeColor = GlassTheme.accentSuccess;
    final Color inactiveColor = isDark 
        ? Colors.grey.shade800.withValues(alpha: 0.6) 
        : Colors.grey.shade400.withValues(alpha: 0.8);

    // Calculate our target logical percentage for the tween (0.0 = left, 1.0 = right)
    double targetProgress = _effectiveValue ? 1.0 : 0.0;
    if (_isDragging && _dragOffset != null) {
      targetProgress = ((_dragOffset! - minLeft) / (maxLeft - minLeft)).clamp(0.0, 1.0);
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onHorizontalDragStart: (details) {
        setState(() {
          _isDragging = true;
          _isPressed = true;
          _dragOffset = _effectiveValue ? maxLeft : minLeft;
        });
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragOffset = (_dragOffset ?? 0) + details.delta.dx;
          _dragOffset = _dragOffset!.clamp(minLeft, maxLeft);
        });
      },
      onHorizontalDragEnd: (details) {
        // Did we cross the midpoint horizontally?
        final bool newValue = (_dragOffset ?? minLeft) > (minLeft + (maxLeft - minLeft) / 2);
        
        setState(() {
          _isDragging = false;
          _isPressed = false;
          _dragOffset = null;
          _optimisticValue = newValue;
        });
        
        if (newValue != widget.value) {
          widget.onChanged(newValue);
        }
      },
      child: SizedBox(
        width: trackWidth + 24,
        height: 38,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            // Track Layer (12px inset to accommodate spring bounce on both sides)
            Positioned(
              left: 12,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: trackWidth,
                height: trackHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(trackHeight / 2),
                  color: _effectiveValue ? activeColor : inactiveColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
              ),
            ),
            // Sub-frame Tweener for Flawless Liquid Physics with Volume Preservation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: targetProgress, end: targetProgress),
              duration: Duration(milliseconds: _isDragging ? 0 : 540),
              curve: _isDragging ? Curves.linear : const _LiquidElasticCurve(),
              builder: (context, progress, child) {
                
                // Map progress to absolute left offset within the track coordinate space
                final double currentLeftLoc = minLeft + (progress * (maxLeft - minLeft));
                
                // AUTHENTIC LIQUID FLUID DYNAMICS (Volume Preservation):
                // In fluid physics, as an elastic droplet stretches horizontally (dx),
                // it naturally pinches vertically (dy) to conserve volume, creating that iconic jiggle!
                final double distanceToCenter = (progress - 0.5).abs();
                final double stretchIntensity = (1.0 - (distanceToCenter / 0.5)).clamp(0.0, 1.0);
                
                // Velocity-based elongation (up to +20px in mid-transit)
                double dynamicWidth = baseKnobWidth + (stretchIntensity * 20.0);
                
                // Volume preservation pinch: height narrows by up to 3.5px during peak velocity
                double dynamicHeight = knobHeight - (stretchIntensity * 3.5);

                // Fluid overshoot squish at impact endpoints
                if (progress < 0.0) {
                  // Overshot left: squashes against left wall (wider, shorter)
                  final leftOvershoot = (-progress).clamp(0.0, 0.4);
                  dynamicWidth += leftOvershoot * 18.0;
                  dynamicHeight -= leftOvershoot * 3.0;
                } else if (progress > 1.0) {
                  // Overshot right: squashes against right wall
                  final rightOvershoot = (progress - 1.0).clamp(0.0, 0.4);
                  dynamicWidth += rightOvershoot * 18.0;
                  dynamicHeight -= rightOvershoot * 3.0;
                }
                
                if (_isPressed && !_isDragging && stretchIntensity < 0.1) {
                  dynamicWidth += 5.0; // tactile fingertip pressure spread
                  dynamicHeight -= 1.5;
                }

                return Positioned(
                  left: 12 + currentLeftLoc, // +12 matches track's left inset
                  child: SizedBox(
                    width: dynamicWidth,
                    height: dynamicHeight,
                    child: child,
                  ),
                );
              },
              child: _LiquidGlassKnob(
                isDark: isDark,
                radius: knobHeight / 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Authentic Liquid Glass specular knob matching the navbar sliding pill.
/// Features backdrop blur, top/bottom specular crescent reflections, and physical depth.
class _LiquidGlassKnob extends StatelessWidget {
  final bool isDark;
  final double radius;

  const _LiquidGlassKnob({
    required this.isDark,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final lensRadius = BorderRadius.circular(radius);

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: lensRadius,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.38)
                  : Colors.black.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.20)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: lensRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: lensRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: 0.22),
                            Colors.white.withValues(alpha: 0.06),
                            Colors.black.withValues(alpha: 0.20),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.88),
                            Colors.white.withValues(alpha: 0.48),
                            Colors.white.withValues(alpha: 0.28),
                          ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 1.0,
                left: 6.0,
                right: 6.0,
                height: 2.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: isDark ? 0.85 : 0.98),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 1.0,
                left: 8.0,
                right: 8.0,
                height: 1.6,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: isDark ? 0.40 : 0.60),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: lensRadius,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.45)
                        : Colors.white.withValues(alpha: 0.85),
                    width: 0.85,
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

/// Authentic Apple iOS Fluid Jelly/Liquid Spring Curve.
/// Simulates high-velocity overshoot followed by two micro-jiggles before rest.
class _LiquidElasticCurve extends Curve {
  const _LiquidElasticCurve();

  @override
  double transformInternal(double t) {
    if (t == 0.0 || t == 1.0) return t;
    final decay = -10.0 * t;
    // Smooth initial surge into a bouncy jelly rebound
    return (1.0 + (decay < -20 ? 0.0 : (3.1415926535 * 0.16 * (1.0 - t) * (1.0 - t))) *
            (t < 0.6 ? 1.0 : (1.0 - t) / 0.4)) *
        Curves.elasticOut.transform(t);
  }
}

