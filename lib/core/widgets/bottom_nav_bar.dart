import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Navigation item definition for the Liquid Glass Navigation Bar / Segmented Control.
class LiquidNavItem {
  final IconData icon;
  final String label;

  const LiquidNavItem({required this.icon, required this.label});
}

/// Apple Liquid Glass Navigation Bar / Segmented Control
///
/// Implements the official Apple Liquid Glass design & interactive physics from
/// Apple's Technology Overviews Segmented Control guide:
///
/// 1. Resting vs Active State Geometry:
///    - In resting/free state, the glass lens is nestled INSIDE the track (height 48px vs track 56px).
///    - On touch or drag, the glass fluidly swells & enlarges (height grows to 66px),
///      visibly protruding 5px above and 5px below the track borders!
/// 2. Liquid Jiggle & Volume Conservation:
///    - Velocity-based mercury stretch along X during motion.
///    - Volume conservation: as X stretches, Y squashes.
///    - On arrival/snap, the liquid droplet exhibits damped harmonic oscillation ("jiggle"),
///      wobbling organically before settling back into its resting well.
/// 3. Luminous Crystal Glass (Non-Dark):
///    - Ultra-clear, high-transmittance glass body with luminous specular highlights.
///    - Directional 315° continuous rim lighting with top-left specular apex and bottom meniscus reflection.
/// 4. Apple System Blue Active Accent:
///    - Under the lens, active icons and labels are rendered in vibrant Apple System Blue (#007AFF).
///    - Outside the lens, inactive items appear in soft Apple System Gray (#8E8E93 / #98989F).
/// 5. Two-Layer Optical Aperture & Meniscus Refraction:
///    - The active layer is 1:1 coordinate-aligned with the base layer, revealed strictly within
///      the lens aperture, with horizontal compression and inward curvature at the curved caps.
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
  late final AnimationController _jiggleCtrl;

  // Real-time floating lens position (0.0 to items.length - 1.0)
  double _position = 0.0;
  double _animStart = 0.0;
  double _animTarget = 0.0;

  bool _isDragging = false;
  bool _isTouching = false;
  double _dragStartDx = 0.0;
  double _dragStartPos = 0.0;
  double _dragVelocity = 0.0;
  int _lastTickedIndex = 0;

  // Jiggle intensity based on impact/arrival velocity
  double _jiggleIntensity = 0.12;

  static const _springCurve = _AppleFluidSpringCurve();

  @override
  void initState() {
    super.initState();
    _position = widget.currentIndex.toDouble();
    _animStart = _position;
    _animTarget = _position;
    _lastTickedIndex = widget.currentIndex;

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    )..addListener(() {
        if (_animCtrl.isAnimating) {
          final t = _springCurve.transform(_animCtrl.value);
          setState(() {
            _position = _animStart + (_animTarget - _animStart) * t;
          });
        }
      });

    // Touch elevation & swell controller:
    // - Forward (touch down): 140ms with easeOutCubic (fast swell, gentle peak)
    // - Reverse (touch off): 160ms with easeInCubic (maximum restoring force at release, snapping down)
    _touchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 160),
    )..addListener(() {
        setState(() {});
      });

    // Liquid droplet jiggle / oscillation controller
    _jiggleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
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
    _jiggleCtrl.dispose();
    _touchCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  /// Calculates physically accurate touch elevation progress:
  /// - Touch-On: easeOutCubic (immediate swell, soft peak)
  /// - Flight: Keeps lens fluidly elevated during transit, docking smoothly into well
  /// - Touch-Off: easeInCubic starts at top velocity, snapping back with maximum restoring force!
  double _getTouchElevationProgress() {
    if (_isTouching || _isDragging) {
      return Curves.easeOutCubic.transform(_touchCtrl.value);
    } else if (_animCtrl.isAnimating) {
      final p = _animCtrl.value;
      final flightElevation = math.sin(p * math.pi);
      final touchVal = Curves.easeInCubic.transform(_touchCtrl.value);
      return math.max(touchVal, flightElevation * 0.85);
    } else {
      return Curves.easeInCubic.transform(_touchCtrl.value);
    }
  }

  void _triggerJiggle(double intensity) {
    _jiggleIntensity = intensity.clamp(0.06, 0.18);
    _jiggleCtrl.forward(from: 0.0);
  }

  void _animateTo(double target) {
    _animCtrl.stop();
    _animStart = _position;
    _animTarget = target;

    // Immediate touch-off release: snap controller back so flight elevation curve guides docking
    _touchCtrl.reverse();

    _animCtrl.forward(from: 0.0).then((_) {
      if (mounted) {
        final dist = (_animTarget - _animStart).abs();
        final intensity = (0.09 + dist * 0.04).clamp(0.08, 0.18);
        _triggerJiggle(intensity);
      }
    });
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

    _isTouching = false;
    _selectTab(tapped);

    // If tapped current tab (no movement), immediately snap down with settle jiggle!
    if (tapped == _lastTickedIndex) {
      _touchCtrl.reverse();
      _triggerJiggle(0.06);
    }
  }

  void _onTapCancel() {
    _isTouching = false;
    _touchCtrl.reverse();
  }

  void _onHorizontalDragStart(DragStartDetails details, double trackWidth) {
    _animCtrl.stop();
    _isDragging = true;
    _dragStartDx = details.localPosition.dx;
    _dragStartPos = _position;
    _dragVelocity = 0.0;
    HapticFeedback.selectionClick();
    _touchCtrl.forward();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double trackWidth) {
    final count = widget.items.length;
    if (count <= 1) return;

    final itemWidth = trackWidth / count;
    final deltaX = details.localPosition.dx - _dragStartDx;
    double nextPos = _dragStartPos + (deltaX / itemWidth);

    // Apple rubber-banding at boundaries
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
    if (velocity.abs() > 320) {
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

    // Track material colors (crisp, translucent Apple glass scrim)
    final trackBg = isDark
        ? const Color(0x241C1C1E) // 14% smoky crystalline dark glass
        : const Color(0x38E5E5EA); // 22% crystalline light glass

    final trackBorder = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.white.withValues(alpha: 0.70);

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
            final slotWidth = barWidth / count;

            // ─── Proportions (Apple Canonical Keyframe & User Spec) ───
            // Total height container: 72.0px.
            // Track height: 56.0px (radius 28.0px).
            // Resting Lens height: 48.0px (inside the track, inset 4px top and bottom).
            // Active Lens height: 66.0px (protrudes 5px above and 5px below track!).
            const containerHeight = 72.0;
            const trackHeight = 56.0;
            const trackRadius = 28.0;
            const restingLensHeight = 48.0;
            const activeLensHeight = 66.0;

            final touchT = _getTouchElevationProgress();

            // ─── Liquid Jiggle Damped Oscillation ───
            double jiggleScaleX = 0.0;
            double jiggleScaleY = 0.0;
            if (_jiggleCtrl.isAnimating) {
              final jt = _jiggleCtrl.value;
              final phase = jt * math.pi * 4.0; // 2 natural liquid ripple cycles
              final decay = math.exp(-4.5 * jt);
              final wave = math.sin(phase) * decay * _jiggleIntensity;
              jiggleScaleX = wave;
              // Volume conservation: Y squashes when X stretches
              jiggleScaleY = -wave * 0.70;
            }

            // Height smoothly swells from resting (48px) to active (66px) + jiggle
            final baseHeight = restingLensHeight + (activeLensHeight - restingLensHeight) * touchT;
            final lensHeight = (baseHeight * (1.0 + jiggleScaleY)).clamp(44.0, 70.0);

            // Insets: Resting insetX is 5.0px (nestled inside); active insetX is 2.5px
            final currentInsetX = 5.0 - (2.5 * touchT);
            final baseLensWidth = slotWidth - (currentInsetX * 2.0);

            // Velocity-based fluid stretching (stretching like liquid mercury in flight)
            double stretchX = 0.0;
            if (_isDragging) {
              stretchX = (_dragVelocity.abs() * 0.50).clamp(0.0, 18.0);
            } else if (_animCtrl.isAnimating) {
              final progress = _animCtrl.value;
              final dist = (_animTarget - _animStart).abs();
              final velocityFactor = (math.sin(progress * math.pi) * dist).clamp(0.0, 1.0);
              stretchX = velocityFactor * 16.0;
            }

            // Volume conservation squash on height during mercury horizontal elongation
            final squashY = -(stretchX * 0.08);
            final effectiveLensHeight = (lensHeight + squashY).clamp(44.0, 70.0);
            final effectiveLensRadius = effectiveLensHeight / 2.0;

            // Width with jiggle and mercury stretch
            final lensWidth = (baseLensWidth + stretchX) * (1.0 + jiggleScaleX);

            final clampedPosition = _position.clamp(-0.25, count - 0.75);
            final lensCenterX = (clampedPosition + 0.5) * slotWidth;
            final lensLeft = lensCenterX - (lensWidth / 2.0);
            final lensTop = (containerHeight - effectiveLensHeight) / 2.0;

            const trackTop = (containerHeight - trackHeight) / 2.0;

            return SizedBox(
              width: barWidth,
              height: containerHeight,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // ─── 1. Outer Translucent Scrim Track (Apple Glass Track) ────────
                  Positioned(
                    top: trackTop,
                    width: barWidth,
                    height: trackHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(trackRadius),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.35)
                                : Colors.black.withValues(alpha: 0.07),
                            blurRadius: 22,
                            offset: const Offset(0, 7),
                          ),
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.18)
                                : Colors.black.withValues(alpha: 0.03),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(trackRadius),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // Track spec: blur 8
                          child: Container(
                            decoration: BoxDecoration(
                              color: trackBg,
                              borderRadius: BorderRadius.circular(trackRadius),
                              border: Border.all(
                                color: trackBorder,
                                width: 0.85,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ─── 2. Inactive Content Layer (Rendered on the Track) ───────────
                  // Underneath the lens, all items appear in muted Apple System Gray.
                  Positioned(
                    top: trackTop,
                    width: barWidth,
                    height: trackHeight,
                    child: Row(
                      children: List.generate(count, (index) {
                        final item = widget.items[index];
                        return Expanded(
                          child: _InactiveNavItem(
                            item: item,
                            isDark: isDark,
                          ),
                        );
                      }),
                    ),
                  ),

                  // ─── 3. Floating Liquid Glass Lens with Active Aperture ──────────
                  // Sits inside when resting; fluidly swells & extends outside when active!
                  Positioned(
                    left: lensLeft,
                    top: lensTop,
                    width: lensWidth,
                    height: effectiveLensHeight,
                    child: _LiquidGlassBubbleAperture(
                      isDark: isDark,
                      lensLeft: lensLeft,
                      lensTop: lensTop,
                      lensWidth: lensWidth,
                      lensHeight: effectiveLensHeight,
                      lensRadius: effectiveLensRadius,
                      barWidth: barWidth,
                      trackTop: trackTop,
                      trackHeight: trackHeight,
                      items: widget.items,
                      touchT: touchT,
                    ),
                  ),

                  // ─── 4. Gesture & Pointer Interaction Layer ──────────────────────
                  Positioned.fill(
                    child: Listener(
                      onPointerDown: (_) {
                        _isTouching = true;
                        _touchCtrl.forward();
                      },
                      onPointerUp: (_) {
                        _isTouching = false;
                        if (!_isDragging && !_animCtrl.isAnimating) {
                          _touchCtrl.reverse();
                          _triggerJiggle(0.06);
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

/// Floating Liquid Glass Lens Aperture
///
/// Implements Apple's optical liquid glass lens architecture:
/// 1. Dynamic 3D elevation drop shadow that lifts and blooms on touch
/// 2. Crystal-clear, luminous, non-dark liquid glass body
/// 3. Active Layer Aperture: Apple System Blue (#007AFF) items aligned 1:1 with base coordinates
/// 4. Optical Meniscus Refraction: Characters passing through the curved caps are
///    horizontally compressed and shifted inward along the meniscus curvature
/// 5. Directional 315° Specular Rim Lighting & Surface Tension Glints
class _LiquidGlassBubbleAperture extends StatelessWidget {
  final bool isDark;
  final double lensLeft;
  final double lensTop;
  final double lensWidth;
  final double lensHeight;
  final double lensRadius;
  final double barWidth;
  final double trackTop;
  final double trackHeight;
  final List<LiquidNavItem> items;
  final double touchT;

  const _LiquidGlassBubbleAperture({
    required this.isDark,
    required this.lensLeft,
    required this.lensTop,
    required this.lensWidth,
    required this.lensHeight,
    required this.lensRadius,
    required this.barWidth,
    required this.trackTop,
    required this.trackHeight,
    required this.items,
    required this.touchT,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(lensRadius);

    // Dynamic 3D elevation shadow: subtle contact shadow when resting, blooms when lifted
    final shadowBlur = 8.0 + (touchT * 14.0);
    final shadowOffset = Offset(0, 2.5 + (touchT * 5.0));
    final shadowAlpha = isDark
        ? (0.28 + (touchT * 0.20))
        : (0.06 + (touchT * 0.08));

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            // Soft ambient elevation shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: shadowAlpha),
              blurRadius: shadowBlur,
              offset: shadowOffset,
            ),
            // Fine contact shadow
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 3.0,
              offset: const Offset(0, 1.0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), // Canonical Apple spec: blur 6
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ─── A. Luminous Crystal-Clear Liquid Body (Never Dark!) ────
                Container(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              Colors.white.withValues(alpha: 0.28), // Crystalline top sheen
                              Colors.white.withValues(alpha: 0.10), // Translucent mid
                              Colors.white.withValues(alpha: 0.04), // Clear base
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.65), // Brilliant light top sheen
                              Colors.white.withValues(alpha: 0.26), // Translucent mid
                              Colors.white.withValues(alpha: 0.12), // Clear base
                            ],
                      stops: const [0.0, 0.50, 1.0],
                    ),
                  ),
                ),

                // ─── B. Active Content Layer (Revealed Through the Lens!) ───
                // Positioned at -lensLeft and (trackTop - lensTop) to align exactly with base items!
                Positioned(
                  left: -lensLeft,
                  top: trackTop - lensTop,
                  width: barWidth,
                  height: trackHeight,
                  child: Row(
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final slotWidth = barWidth / items.length;
                      final itemCenterScreenX = (index + 0.5) * slotWidth;

                      // Calculate optical meniscus refraction near curved caps
                      final leftCapEdge = lensLeft;
                      final rightCapEdge = lensLeft + lensWidth;
                      final distToLeft = itemCenterScreenX - leftCapEdge;
                      final distToRight = rightCapEdge - itemCenterScreenX;

                      double compressX = 1.0;
                      double shiftX = 0.0;
                      const meniscusThreshold = 38.0;

                      if (distToLeft < meniscusThreshold && distToLeft > -20.0) {
                        // Squeezed and refracted at left meniscus cap
                        final ratio = (distToLeft / meniscusThreshold).clamp(0.0, 1.0);
                        compressX = 0.82 + (0.18 * ratio);
                        shiftX = 3.5 * (1.0 - ratio);
                      } else if (distToRight < meniscusThreshold && distToRight > -20.0) {
                        // Squeezed and refracted at right meniscus cap
                        final ratio = (distToRight / meniscusThreshold).clamp(0.0, 1.0);
                        compressX = 0.82 + (0.18 * ratio);
                        shiftX = -3.5 * (1.0 - ratio);
                      }

                      return Expanded(
                        child: Transform.translate(
                          offset: Offset(shiftX, 0.0),
                          child: Transform.scale(
                            scaleX: compressX,
                            scaleY: 1.02,
                            child: _ActiveNavItem(
                              item: item,
                              isDark: isDark,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // ─── C. Custom Specular 315° Rim & Meniscus Refraction ──
                Positioned.fill(
                  child: CustomPaint(
                    painter: _AppleLiquidGlassSegmentPainter(
                      isDark: isDark,
                      radius: lensRadius,
                    ),
                  ),
                ),

                // ─── D. Top Specular Glint Line (Surface Tension) ───────
                Positioned(
                  top: 1.2,
                  left: lensRadius * 0.75,
                  right: lensRadius * 0.75,
                  height: 1.8,
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

                // ─── E. Bottom Ambient Floor Bounce ─────────────────────
                Positioned(
                  bottom: 1.2,
                  left: lensRadius * 0.85,
                  right: lensRadius * 0.85,
                  height: 1.4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: isDark ? 0.35 : 0.65),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
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

/// Inactive Navigation Item (Base Layer)
///
/// Underneath the lens, inactive tabs are rendered in muted Apple System Gray:
/// - Light: #8E8E93, regular weight
/// - Dark: #98989F, regular weight
class _InactiveNavItem extends StatelessWidget {
  final LiquidNavItem item;
  final bool isDark;

  const _InactiveNavItem({
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDark ? const Color(0xFF98989F) : const Color(0xFF8E8E93);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          item.icon,
          size: 21,
          color: color,
        ),
        const SizedBox(height: 3),
        Text(
          item.label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: color,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Active Navigation Item (Inside Lens Aperture)
///
/// Inside the floating lens, active items are vibrant Apple System Blue:
/// - Color: CupertinoColors.systemBlue (#007AFF)
/// - Bold typography: FontWeight.w700
/// - Crisp filled icon glyph
class _ActiveNavItem extends StatelessWidget {
  final LiquidNavItem item;
  final bool isDark;

  const _ActiveNavItem({
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Apple System Blue active accent (#007AFF)
    const activeColor = CupertinoColors.systemBlue;

    // Resolve filled active icon variant automatically
    IconData activeIcon = item.icon;
    if (item.icon.codePoint == 0xf699) {
      activeIcon = const IconData(0xf69a, fontFamily: 'CupertinoIcons', fontPackage: 'cupertino_icons'); // house_fill
    } else if (item.icon.codePoint == 0xf760) {
      activeIcon = const IconData(0xf761, fontFamily: 'CupertinoIcons', fontPackage: 'cupertino_icons'); // square_grid_2x2_fill
    } else if (item.icon.codePoint == 0xf7a5) {
      activeIcon = const IconData(0xf7a6, fontFamily: 'CupertinoIcons', fontPackage: 'cupertino_icons'); // person_fill
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          activeIcon,
          size: 22.5,
          color: activeColor,
        ),
        const SizedBox(height: 3),
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: activeColor,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Directional Specular Capsule Rim & Meniscus Refraction Painter
///
/// Paints:
/// 1. Continuous, razor-sharp 1.1px specular rim contour lit at 315°
/// 2. Delicate internal reflection / meniscus refraction shadow arcs at curved caps
/// 3. Bottom luminous reflection arc
class _AppleLiquidGlassSegmentPainter extends CustomPainter {
  final bool isDark;
  final double radius;

  const _AppleLiquidGlassSegmentPainter({
    required this.isDark,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.5, 0.5, size.width - 1.0, size.height - 1.0);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius - 0.5));

    // 1. Subtle internal reflection shadow along curved meniscus caps (never muddy)
    final leftCapCenter = Offset(radius, size.height / 2);
    final leftCapPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..shader = RadialGradient(
        center: const Alignment(-0.85, 0.0),
        radius: 0.9,
        colors: [
          isDark
              ? Colors.black.withValues(alpha: 0.20)
              : Colors.black.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.72, 1.0],
      ).createShader(Rect.fromCircle(center: leftCapCenter, radius: radius));

    canvas.drawRRect(rrect, leftCapPaint);

    // 2. Baseline Glass Contour Outline
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.16)
          : Colors.white.withValues(alpha: 0.45);
    canvas.drawRRect(rrect, basePaint);

    // 3. Continuous Specular Rim Highlight (Light @ 315°)
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..shader = LinearGradient(
        begin: const Alignment(-0.8, -1.0),
        end: const Alignment(0.8, 1.0),
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.88), // Lit top-left apex
                Colors.white.withValues(alpha: 0.48), // Top
                Colors.white.withValues(alpha: 0.12), // Trailing edge
                Colors.white.withValues(alpha: 0.42), // Bottom inner bounce
              ]
            : [
                Colors.white.withValues(alpha: 0.98), // Lit top-left apex
                Colors.white.withValues(alpha: 0.75), // Top
                Colors.white.withValues(alpha: 0.22), // Trailing edge
                Colors.white.withValues(alpha: 0.70), // Bottom inner bounce
              ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(rrect.outerRect);

    canvas.drawRRect(rrect, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _AppleLiquidGlassSegmentPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.radius != radius;
  }
}

/// Apple Fluid Spring Curve
///
/// Accurately implements Apple's critically damped fluid spring (damping: 0.76, omega: 8.5)
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
