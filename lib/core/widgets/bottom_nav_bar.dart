import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Navigation item definition for the Liquid Glass Navigation Bar.
class LiquidNavItem {
  final IconData icon;
  final String label;

  const LiquidNavItem({required this.icon, required this.label});
}

// Custom navigation bar
class LiquidGlassNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<LiquidNavItem> items;
  final bool isDark;

  const LiquidGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.isDark,
  });

  @override
  State<LiquidGlassNavBar> createState() => _LiquidGlassNavBarState();
}

class _LiquidGlassNavBarState extends State<LiquidGlassNavBar>
    with TickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final AnimationController _touchCtrl;

  // Real-time floating lens position between 0.0 and (items.length - 1)
  double _position = 0.0;
  double _animStart = 0.0;
  double _animTarget = 0.0;

  bool _isDragging = false;
  bool _isTouching = false;
  double _dragStartDx = 0.0;
  double _dragStartPos = 0.0;
  double _dragVelocity = 0.0;
  int _lastTickedIndex = 0;

  static const _springCurve = _AppleFluidSpringCurve();
  static const _touchCurve = Curves.easeOutCubic;

  @override
  void initState() {
    super.initState();
    _position = widget.currentIndex.toDouble();
    _animStart = _position;
    _animTarget = _position;
    _lastTickedIndex = widget.currentIndex;

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..addListener(() {
        if (_animCtrl.isAnimating) {
          final t = _springCurve.transform(_animCtrl.value);
          setState(() {
            _position = _animStart + (_animTarget - _animStart) * t;
          });
        }
      });

    // Dedicated touch-responsive expansion controller
    _touchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      reverseDuration: const Duration(milliseconds: 220),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(covariant LiquidGlassNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex && !_isDragging) {
      _animateTo(widget.currentIndex.toDouble());
    }
  }

  @override
  void dispose() {
    _touchCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _animCtrl.stop();
    _animStart = _position;
    _animTarget = target;
    _animCtrl.forward(from: 0.0);
  }

  void _selectTab(int index) {
    if (index != widget.currentIndex) {
      HapticFeedback.lightImpact();
      widget.onTap(index);
    } else {
      HapticFeedback.selectionClick();
    }
    _lastTickedIndex = index;
    _animateTo(index.toDouble());
  }

  void _onTapDown(TapDownDetails details) {
    _isTouching = true;
    _touchCtrl.forward();
  }

  void _onTapUp(TapUpDetails details, double trackWidth) {
    final count = widget.items.length;
    if (count == 0) return;
    final itemWidth = trackWidth / count;
    final tapped = (details.localPosition.dx / itemWidth).floor().clamp(0, count - 1);

    _selectTab(tapped);

    // Smoothly return to normal resting size after brief tap swell
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted && !_isTouching && !_isDragging) {
        _touchCtrl.reverse();
      }
    });
  }

  void _onTapCancel() {
    if (!_isTouching && !_isDragging) {
      _touchCtrl.reverse();
    }
  }

  void _onHorizontalDragStart(DragStartDetails details, double trackWidth) {
    _animCtrl.stop();
    _isDragging = true;
    _dragStartDx = details.localPosition.dx;
    _dragStartPos = _position;
    _dragVelocity = 0.0;
    HapticFeedback.selectionClick();
    _touchCtrl.forward(); // Expand and maintain throughout drag
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double trackWidth) {
    final count = widget.items.length;
    if (count <= 1) return;

    final itemWidth = trackWidth / count;
    final deltaX = details.localPosition.dx - _dragStartDx;
    double nextPos = _dragStartPos + (deltaX / itemWidth);

    // Physical rubber-banding outside boundaries
    if (nextPos < 0.0) {
      nextPos = nextPos * 0.28;
    } else if (nextPos > count - 1.0) {
      nextPos = (count - 1.0) + (nextPos - (count - 1.0)) * 0.28;
    }

    setState(() {
      _dragVelocity = details.primaryDelta ?? 0.0;
      _position = nextPos;

      // Haptic tick precisely as the finger moves past a tab center
      final nearest = _position.round().clamp(0, count - 1);
      if (nearest != _lastTickedIndex && (_position - nearest).abs() < 0.24) {
        _lastTickedIndex = nearest;
        HapticFeedback.selectionClick();
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double trackWidth) {
    _isDragging = false;
    _isTouching = false;
    final count = widget.items.length;
    final velocity = details.primaryVelocity ?? 0.0;

    int target = _position.round();

    // Fast flick detection
    if (velocity.abs() > 360) {
      if (velocity > 0) {
        target = (_position.floor() + 1);
      } else {
        target = (_position.ceil() - 1);
      }
    }
    target = target.clamp(0, count - 1);

    HapticFeedback.mediumImpact();
    widget.onTap(target);
    _lastTickedIndex = target;
    _animateTo(target.toDouble());

    // Smoothly return to normal resting dimensions on release
    _touchCtrl.reverse();
  }

  void _onHorizontalDragCancel() {
    _isDragging = false;
    _isTouching = false;
    _animateTo(_lastTickedIndex.toDouble());
    _touchCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final count = widget.items.length;

    // Translucent outer pill specifications
    final outerBg = isDark
        ? const Color(0x331C1C1E) // 20% smoky dark glass
        : const Color(0x66F8F8FC); // 40% crystalline light glass

    final outerBorder = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.white.withValues(alpha: 0.72);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          0,
          18,
          (bottomInset > 0 ? bottomInset : 14) + 6,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            final itemWidth = barWidth / count;
            const barHeight = 62.0;

            // ─── Fine-Tuned Pill Geometry (Substantial Resting + Full-Height Active) ────
            // 1. Resting Insets (slightly larger resting pill with comfortable breathing room):
            // Horizontal inset: 7.0 logical pixels on each side (6-8px target)
            // Vertical inset: 4.5 logical pixels above and below (4-5px target)
            const restingInsetX = 7.0;
            const restingInsetY = 4.5;

            // 2. Active Touch-Expanded Insets (nearly full slot height):
            // Vertical clearance: 1.5 logical pixels (1-2px target) -> expands to 59px inside 62px slot
            // Horizontal clearance: 4.0 logical pixels (3-5px target) -> controlled horizontal growth
            const activeInsetY = 1.5;
            const activeInsetX = 4.0;

            // Smooth touch-responsive transition (t: 0.0 resting -> 1.0 active)
            final t = _touchCurve.transform(_touchCtrl.value);
            final currentInsetX = restingInsetX + (activeInsetX - restingInsetX) * t;
            final currentInsetY = restingInsetY + (activeInsetY - restingInsetY) * t;

            // Target dimensions:
            final baseLensHeight = barHeight - (currentInsetY * 2);
            final baseLensWidth = itemWidth - (currentInsetX * 2);

            // Elastic stretching calculation based on drag velocity & flight phase
            double stretchX = 0.0;
            if (_isDragging) {
              stretchX = (_dragVelocity.abs() * 0.35).clamp(0.0, 10.0);
            } else if (_animCtrl.isAnimating) {
              final progress = _animCtrl.value;
              final dist = (_animTarget - _animStart).abs();
              final velocityFactor = (math.sin(progress * math.pi) * dist).clamp(0.0, 1.0);
              stretchX = velocityFactor * 10.0;
            }

            final clampedPosition = _position.clamp(-0.25, count - 0.75);
            final lensLeft = (clampedPosition * itemWidth) + currentInsetX - (stretchX * 0.5);
            final lensWidth = baseLensWidth + stretchX;
            final lensTop = currentInsetY;
            final lensHeight = baseLensHeight;

            return SizedBox(
              width: barWidth,
              height: barHeight,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // ─── 1. Outer Translucent Glass Bar ──────────────────────────────
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(31),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.40)
                                : Colors.black.withValues(alpha: 0.08),
                            blurRadius: 26,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.20)
                                : Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(31),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                          child: Container(
                            decoration: BoxDecoration(
                              color: outerBg,
                              borderRadius: BorderRadius.circular(31),
                              border: Border.all(
                                color: outerBorder,
                                width: 0.85,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ─── 2. The Moving Liquid Glass Selection Lens (Smaller Inset Capsule) ──
                  Positioned(
                    left: lensLeft,
                    top: lensTop,
                    width: lensWidth,
                    height: lensHeight,
                    child: IgnorePointer(
                      child: _LiquidGlassBubble(
                        isDark: isDark,
                        radius: lensHeight / 2,
                      ),
                    ),
                  ),

                  // ─── 3. Unified Direct Touch & Gesture Layer ─────────────────────
                  Positioned.fill(
                    child: Listener(
                      onPointerDown: (_) {
                        _isTouching = true;
                        _touchCtrl.forward();
                      },
                      onPointerUp: (_) {
                        _isTouching = false;
                        if (!_isDragging) {
                          Future.delayed(const Duration(milliseconds: 140), () {
                            if (mounted && !_isTouching && !_isDragging) {
                              _touchCtrl.reverse();
                            }
                          });
                        }
                      },
                      onPointerCancel: (_) {
                        _isTouching = false;
                        _isDragging = false;
                        _touchCtrl.reverse();
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: _onTapDown,
                        onTapUp: (d) => _onTapUp(d, barWidth),
                        onTapCancel: _onTapCancel,
                        onHorizontalDragStart: (d) => _onHorizontalDragStart(d, barWidth),
                        onHorizontalDragUpdate: (d) => _onHorizontalDragUpdate(d, barWidth),
                        onHorizontalDragEnd: (d) => _onHorizontalDragEnd(d, barWidth),
                        onHorizontalDragCancel: _onHorizontalDragCancel,
                        child: Row(
                          children: List.generate(count, (index) {
                            final item = widget.items[index];
                            final dist = (_position - index).abs();
                            final progress = (1.0 - dist).clamp(0.0, 1.0);

                            return Expanded(
                              child: _NavItemContent(
                                item: item,
                                isDark: isDark,
                                progress: progress,
                                onSemanticsTap: () => _selectTab(index),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Floating glass highlight bubble
class _LiquidGlassBubble extends StatelessWidget {
  final bool isDark;
  final double radius;

  const _LiquidGlassBubble({
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
            // Soft ambient drop shadow giving physical depth
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.38)
                  : Colors.black.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
            // Contact shadow
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
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Adaptive Liquid Glass Body Fill
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

                // 2. Pure Monochromatic Specular Top Crescent Sheen
                Positioned(
                  top: 1.0,
                  left: 8.0,
                  right: 8.0,
                  height: 2.2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: isDark ? 0.78 : 0.95),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // 3. Pure Monochromatic Specular Bottom Floor Reflection
                Positioned(
                  bottom: 1.0,
                  left: 10.0,
                  right: 10.0,
                  height: 1.8,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: isDark ? 0.32 : 0.52),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // 4. Subtle Ambient Perimeter Outline
                Container(
                  decoration: BoxDecoration(
                    borderRadius: lensRadius,
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.30)
                          : Colors.white.withValues(alpha: 0.75),
                      width: 0.85,
                    ),
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

/// Navigation item content: icon & typography with Apple System Blue active accent.
class _NavItemContent extends StatelessWidget {
  final LiquidNavItem item;
  final bool isDark;
  final double progress; // 0.0 (inactive) to 1.0 (active)
  final VoidCallback? onSemanticsTap;

  const _NavItemContent({
    required this.item,
    required this.isDark,
    required this.progress,
    this.onSemanticsTap,
  });

  @override
  Widget build(BuildContext context) {
    // Apple System Blue active accent (#007AFF)
    const activeColor = CupertinoColors.systemBlue;
    final inactiveColor = isDark
        ? const Color(0xFF98989F) // Apple System Gray
        : const Color(0xFF8E8E93);

    final color = Color.lerp(inactiveColor, activeColor, progress)!;
    final scale = 1.0 + (progress * 0.07);

    return Semantics(
      button: true,
      label: item.label,
      selected: progress > 0.5,
      onTap: onSemanticsTap,
      child: Transform.scale(
        scale: scale,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: progress > 0.5 ? FontWeight.w600 : FontWeight.w500,
                color: color,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Spring curve animation
class _AppleFluidSpringCurve extends Curve {
  const _AppleFluidSpringCurve();

  @override
  double transformInternal(double t) {
    const double damping = 0.76;
    const double omega = 8.5;
    final double omegaD = omega * math.sqrt(1.0 - damping * damping);
    final double decay = math.exp(-damping * omega * t);
    final double response = 1.0 -
        decay *
            (math.cos(omegaD * t) +
                (damping / math.sqrt(1.0 - damping * damping)) *
                    math.sin(omegaD * t));
    return response.clamp(-0.15, 1.06);
  }

  @override
  double transform(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    return super.transform(t);
  }
}
