import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/custom_toast.dart';
import '../../core/widgets/circular_glass_button.dart';
import '../../providers/category_provider.dart';
import '../../providers/focus_provider.dart';
import '../../providers/task_provider.dart';
import 'widgets/timer_dial_painter.dart';

class FocusControlCenterModal extends ConsumerWidget {
  const FocusControlCenterModal({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.mediumImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'FocusModal',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, anim1, anim2) => const FocusControlCenterModal(),
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 24 * curved.value,
            sigmaY: 24 * curved.value,
          ),
          child: FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.90, end: 1.0).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusState = ref.watch(focusProvider);
    final focusNotifier = ref.read(focusProvider.notifier);
    final tasks = ref.watch(taskProvider);
    final categories = ref.watch(categoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pendingTasks = tasks.where((t) => !t.isCompleted).toList();
    final activeTask = focusState.activeTask ??
        (pendingTasks.isNotEmpty ? pendingTasks.first : null);

    final minutes = (focusState.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (focusState.remainingSeconds % 60).toString().padLeft(2, '0');

    // Get custom user-selected color or active task's category color or electric iOS royal blue default
    Color taskAccentColor = focusState.customColorValue != null
        ? Color(focusState.customColorValue!)
        : const Color(0xFF0A84FF);
    if (focusState.customColorValue == null && activeTask != null && activeTask.categoryId != null) {
      final cat = categories.cast().where((c) => c.id == activeTask.categoryId).firstOrNull;
      if (cat != null) {
        taskAccentColor = Color(cat.colorValue);
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Top Bar: Modal Title & Sliding Glass Capsule Selector ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sliding Pill for "Clock 1" vs "Clock 2"
                    _SlidingClockPill(
                      clockStyle: focusState.clockStyle,
                      onSelect: (style) {
                        HapticFeedback.selectionClick();
                        focusNotifier.setClockStyle(style);
                      },
                      isDark: isDark,
                      accentColor: taskAccentColor,
                    ),

                    // Close Button (Sticky Note X-Button Design)
                    CircularGlassButton(
                      size: 38,
                      icon: CupertinoIcons.xmark,
                      iconSize: 15,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ══════════════════════════════════════════════════════════════
                // ─── MASTER COMPONENT: AUTHENTIC LIQUID GLASS SQUIRCLE PLAYER ─
                // ══════════════════════════════════════════════════════════════
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(46), // Apple continuous squircle
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                        blurRadius: 36,
                        offset: const Offset(0, 16),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(46),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Stack(
                        children: [
                          // ── Layer 2: Master Container Refractive Glass Body ──
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(46),
                                gradient: RadialGradient(
                                  center: const Alignment(-0.25, -0.40),
                                  radius: 1.25,
                                  colors: isDark
                                      ? [
                                          Colors.white.withValues(alpha: 0.16),
                                          Colors.white.withValues(alpha: 0.06),
                                          Colors.black.withValues(alpha: 0.24),
                                        ]
                                      : [
                                          Colors.white.withValues(alpha: 0.94),
                                          Colors.white.withValues(alpha: 0.68),
                                          Colors.white.withValues(alpha: 0.48),
                                        ],
                                  stops: const [0.0, 0.60, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // ── Layer 3: 315° Specular Glass Rim Outline ──
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: PillGlassRimPainter(
                                  isDark: isDark,
                                  borderRadius: 46,
                                ),
                              ),
                            ),
                          ),
                          // ── Layer 4: Content Deck ──
                          Padding(
                            padding: const EdgeInsets.all(26),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Top Row: Morphed Squircle Dial & Dynamic Digital Countdown Stage ──
                                _FocusClockStage(
                                  state: focusState,
                                  minutes: minutes,
                                  seconds: seconds,
                                  accentColor: taskAccentColor,
                                  isDark: isDark,
                                  onColorTap: () {
                                    HapticFeedback.selectionClick();
                                    focusNotifier.cycleColor();
                                  },
                                ),
                          const SizedBox(height: 12),

                          // ── Track Info: Task Title & Subtitle / Note ──
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activeTask?.title ?? 'Deep Focus Session',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      activeTask?.note != null && activeTask!.note!.isNotEmpty
                                          ? activeTask.note!
                                          : (focusState.isRunning ? 'Focusing in progress' : 'Ready to start'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.60)
                                            : Colors.black.withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (activeTask != null)
                                CircularGlassButton(
                                  size: 36,
                                  icon: CupertinoIcons.checkmark_alt,
                                  iconSize: 17,
                                  iconColor: activeTask.isCompleted
                                      ? const Color(0xFF34C759)
                                      : null,
                                  isDark: isDark,
                                  onTap: () {
                                    HapticFeedback.mediumImpact();
                                    ref.read(taskProvider.notifier).toggleComplete(activeTask.id);
                                    GlassToast.show(
                                      context,
                                      message: 'Task completed! Great work!',
                                      icon: CupertinoIcons.checkmark_circle_fill,
                                      iconColor: const Color(0xFF34C759),
                                    );
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // ── Glass Scrubber / Progress Bar ──
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              height: 5,
                              width: double.infinity,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.08),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: focusState.progress.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: taskAccentColor,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: taskAccentColor.withValues(alpha: 0.7),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Playback Controls Deck: Back ⏪, Play/Pause ▶️, Forward ⏩ ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Previous / Reset
                              _PlayerIconButton(
                                icon: CupertinoIcons.backward_fill,
                                size: 28,
                                isDark: isDark,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  focusNotifier.reset();
                                },
                              ),

                              // Big Center Glass Play / Pause (iOS Music Style)
                              _PlayerGlassPlayPause(
                                isRunning: focusState.isRunning,
                                accentColor: taskAccentColor,
                                isDark: isDark,
                                onTap: () {
                                  HapticFeedback.heavyImpact();
                                  focusNotifier.togglePlayPause();
                                },
                              ),

                              // Next Task / Skip
                              _PlayerIconButton(
                                icon: CupertinoIcons.forward_fill,
                                size: 28,
                                isDark: isDark,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  if (pendingTasks.isNotEmpty) {
                                    final curIdx = pendingTasks.indexOf(activeTask ?? pendingTasks.first);
                                    final nextIdx = (curIdx + 1) % pendingTasks.length;
                                    focusNotifier.setTask(pendingTasks[nextIdx]);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Preset Quick Durations (15m default, 25m, 45m) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [15, 25, 45].map((mins) {
              final isCurrent = focusState.totalSeconds == mins * 60;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: LiquidGlassPillButton(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    focusNotifier.setDuration(mins);
                  },
                  isDark: isDark,
                  isSelected: isCurrent,
                  selectedColor: taskAccentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Text(
                    '${mins}m',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isCurrent
                          ? Colors.white
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.85)
                              : const Color(0xFF111111)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Apple Fluid Spring Curve ────────────────────────────────────────────────

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

// ─── Sliding Liquid Glass Navbar Capsule (Clock 1 vs Clock 2) ────────────────

class _SlidingClockPill extends StatefulWidget {
  final FocusClockStyle clockStyle;
  final ValueChanged<FocusClockStyle> onSelect;
  final bool isDark;
  final Color accentColor;

  const _SlidingClockPill({
    required this.clockStyle,
    required this.onSelect,
    required this.isDark,
    required this.accentColor,
  });

  @override
  State<_SlidingClockPill> createState() => _SlidingClockPillState();
}

class _SlidingClockPillState extends State<_SlidingClockPill>
    with TickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final AnimationController _touchCtrl;
  late final AnimationController _jiggleCtrl;

  // Real-time floating lens position (0.0 to 1.0)
  double _position = 0.0;
  double _animStart = 0.0;
  double _animTarget = 0.0;

  bool _isDragging = false;
  bool _isTouching = false;
  double _dragStartDx = 0.0;
  double _dragStartPos = 0.0;
  double _dragVelocity = 0.0;
  int _lastTickedIndex = 0;

  double _jiggleIntensity = 0.12;
  static const _springCurve = _AppleFluidSpringCurve();

  @override
  void initState() {
    super.initState();
    _position = widget.clockStyle == FocusClockStyle.clock1 ? 0.0 : 1.0;
    _animStart = _position;
    _animTarget = _position;
    _lastTickedIndex = widget.clockStyle == FocusClockStyle.clock1 ? 0 : 1;

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

    _touchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 160),
    )..addListener(() {
        setState(() {});
      });

    _jiggleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(covariant _SlidingClockPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.clockStyle == FocusClockStyle.clock1 ? 0.0 : 1.0;
    if (oldWidget.clockStyle != widget.clockStyle && !_isDragging) {
      if ((_animTarget - target).abs() > 0.01) {
        _animateTo(target);
      }
    }
  }

  @override
  void dispose() {
    _jiggleCtrl.dispose();
    _touchCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

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

    _touchCtrl.reverse();

    _animCtrl.forward(from: 0.0).then((_) {
      if (mounted) {
        final dist = (_animTarget - _animStart).abs();
        final intensity = (0.09 + dist * 0.05).clamp(0.08, 0.18);
        _triggerJiggle(intensity);
      }
    });
  }

  void _selectTab(int index) {
    final style = index == 0 ? FocusClockStyle.clock1 : FocusClockStyle.clock2;
    if (widget.clockStyle != style) {
      HapticFeedback.lightImpact();
      widget.onSelect(style);
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
    final slotWidth = trackWidth / 2.0;
    final tapped = (details.localPosition.dx / slotWidth).floor().clamp(0, 1);

    _isTouching = false;
    _selectTab(tapped);

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
    final slotWidth = trackWidth / 2.0;
    final deltaX = details.localPosition.dx - _dragStartDx;
    double nextPos = _dragStartPos + (deltaX / slotWidth);

    if (nextPos < 0.0) {
      nextPos = nextPos * 0.28;
    } else if (nextPos > 1.0) {
      nextPos = 1.0 + (nextPos - 1.0) * 0.28;
    }

    setState(() {
      _dragVelocity = details.primaryDelta ?? 0.0;
      _position = nextPos;

      final nearest = _position.round().clamp(0, 1);
      if (nearest != _lastTickedIndex && (_position - nearest).abs() < 0.24) {
        _lastTickedIndex = nearest;
        HapticFeedback.selectionClick();
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double trackWidth) {
    _isDragging = false;
    _isTouching = false;
    final velocity = details.primaryVelocity ?? 0.0;

    int target = _position.round();
    if (velocity.abs() > 280) {
      if (velocity > 0) {
        target = 1;
      } else {
        target = 0;
      }
    }
    target = target.clamp(0, 1);

    HapticFeedback.mediumImpact();
    final style = target == 0 ? FocusClockStyle.clock1 : FocusClockStyle.clock2;
    widget.onSelect(style);
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
    const trackWidth = 192.0;
    const trackHeight = 40.0;
    const trackRadius = 20.0;
    const containerHeight = 54.0;
    const restingLensHeight = 34.0;
    const activeLensHeight = 48.0;
    const slotWidth = trackWidth / 2.0;

    final touchT = _getTouchElevationProgress();

    // Liquid Jiggle
    double jiggleScaleX = 0.0;
    double jiggleScaleY = 0.0;
    if (_jiggleCtrl.isAnimating) {
      final jt = _jiggleCtrl.value;
      final phase = jt * math.pi * 4.0;
      final decay = math.exp(-4.5 * jt);
      final wave = math.sin(phase) * decay * _jiggleIntensity;
      jiggleScaleX = wave;
      jiggleScaleY = -wave * 0.70;
    }

    final baseHeight = restingLensHeight + (activeLensHeight - restingLensHeight) * touchT;
    final lensHeight = (baseHeight * (1.0 + jiggleScaleY)).clamp(32.0, 52.0);

    final currentInsetX = 4.0 - (2.0 * touchT);
    final baseLensWidth = slotWidth - (currentInsetX * 2.0);

    double stretchX = 0.0;
    if (_isDragging) {
      stretchX = (_dragVelocity.abs() * 0.45).clamp(0.0, 14.0);
    } else if (_animCtrl.isAnimating) {
      final progress = _animCtrl.value;
      final dist = (_animTarget - _animStart).abs();
      final velocityFactor = (math.sin(progress * math.pi) * dist).clamp(0.0, 1.0);
      stretchX = velocityFactor * 14.0;
    }

    final squashY = -(stretchX * 0.08);
    final effectiveLensHeight = (lensHeight + squashY).clamp(32.0, 52.0);
    final effectiveLensRadius = effectiveLensHeight / 2.0;

    final lensWidth = (baseLensWidth + stretchX) * (1.0 + jiggleScaleX);

    final clampedPosition = _position.clamp(-0.20, 1.20);
    final lensCenterX = (clampedPosition + 0.5) * slotWidth;
    final lensLeft = lensCenterX - (lensWidth / 2.0);
    final lensTop = (containerHeight - effectiveLensHeight) / 2.0;
    const trackTop = (containerHeight - trackHeight) / 2.0;

    // Track material colors
    final trackBg = isDark
        ? const Color(0x241C1C1E)
        : const Color(0x38E5E5EA);

    final trackBorder = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.white.withValues(alpha: 0.70);

    return SizedBox(
      width: trackWidth,
      height: containerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // ── 1. Outer Translucent Scrim Track (Apple Glass Track) ──
          Positioned(
            top: trackTop,
            width: trackWidth,
            height: trackHeight,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(trackRadius),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.35)
                        : Colors.black.withValues(alpha: 0.07),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(trackRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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

          // ── 2. Inactive Content Layer (Rendered on the Track in Apple System Gray) ──
          Positioned(
            top: trackTop,
            width: trackWidth,
            height: trackHeight,
            child: Row(
              children: const [
                Expanded(
                  child: Center(
                    child: Text(
                      'Clock 1',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8E8E93),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Clock 2',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8E8E93),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 3. Floating Liquid Glass Lens with Active Aperture ──
          Positioned(
            left: lensLeft,
            top: lensTop,
            width: lensWidth,
            height: effectiveLensHeight,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(effectiveLensRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark
                          ? (0.28 + touchT * 0.12)
                          : (0.10 + touchT * 0.06),
                    ),
                    blurRadius: 10 + (touchT * 4),
                    offset: Offset(0, 2 + (touchT * 1.5)),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(effectiveLensRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Stack(
                    children: [
                      // Refractive Glass Body
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(effectiveLensRadius),
                            gradient: RadialGradient(
                              center: const Alignment(-0.25, -0.35),
                              radius: 1.1,
                              colors: isDark
                                  ? [
                                      Colors.white.withValues(alpha: 0.24),
                                      Colors.white.withValues(alpha: 0.09),
                                      Colors.black.withValues(alpha: 0.22),
                                    ]
                                  : [
                                      Colors.white.withValues(alpha: 0.95),
                                      Colors.white.withValues(alpha: 0.65),
                                      Colors.white.withValues(alpha: 0.40),
                                    ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Active Content Layer (Revealed Through the Lens Aperture)
                      Positioned(
                        left: -lensLeft,
                        top: trackTop - lensTop,
                        width: trackWidth,
                        height: trackHeight,
                        child: Row(
                          children: const [
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Clock 1',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF007AFF),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Clock 2',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF007AFF),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 315° Specular Rim
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: PillGlassRimPainter(
                              isDark: isDark,
                              borderRadius: effectiveLensRadius,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── 4. Gesture & Pointer Interaction Layer ──
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
                onTapUp: (d) => _onTapUp(d, trackWidth),
                onTapCancel: _onTapCancel,
                onHorizontalDragStart: (d) => _onHorizontalDragStart(d, trackWidth),
                onHorizontalDragUpdate: (d) => _onHorizontalDragUpdate(d, trackWidth),
                onHorizontalDragEnd: (d) => _onHorizontalDragEnd(d, trackWidth),
                onHorizontalDragCancel: _onHorizontalDragCancel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Focus Clock Morph Stage (Sticky Notes Grid-to-Open Butter Smooth Transition) ──

class _FocusClockStage extends StatefulWidget {
  final FocusState state;
  final String minutes;
  final String seconds;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onColorTap;

  const _FocusClockStage({
    required this.state,
    required this.minutes,
    required this.seconds,
    required this.accentColor,
    required this.isDark,
    required this.onColorTap,
  });

  @override
  State<_FocusClockStage> createState() => _FocusClockStageState();
}

class _FocusClockStageState extends State<_FocusClockStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _morphCtrl;
  late final Animation<double> _morphCurve;

  @override
  void initState() {
    super.initState();
    _morphCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 440),
      value: widget.state.clockStyle == FocusClockStyle.clock1 ? 0.0 : 1.0,
    );
    _morphCurve = CurvedAnimation(
      parent: _morphCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void didUpdateWidget(covariant _FocusClockStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.clockStyle != widget.state.clockStyle) {
      if (widget.state.clockStyle == FocusClockStyle.clock2) {
        _morphCtrl.forward();
      } else {
        _morphCtrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _morphCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _morphCurve,
      builder: (context, _) {
        final t = _morphCurve.value;

        return LayoutBuilder(
          builder: (context, constraints) {
            final stageWidth = constraints.maxWidth;

            // Butter-smooth morph: Clock 1 (top-left 96x96, radius 26) <-> Clock 2 (center 148x148, radius 38)
            final dialSize = lerpDouble(96.0, 148.0, t)!;
            final dialRadius = lerpDouble(26.0, 38.0, t)!;
            final dialLeft = lerpDouble(0.0, (stageWidth - dialSize) / 2.0, t)!;
            final dialTop = lerpDouble(0.0, 6.0, t)!;

            // Countdown digits smoothly glide down & scale from 58px to 40px
            final timeTop = lerpDouble(110.0, 168.0, t)!;
            final digitsFontSize = lerpDouble(58.0, 40.0, t)!;
            final colonFontSize = lerpDouble(48.0, 34.0, t)!;
            final letterSpacing = lerpDouble(-2.0, -1.5, t)!;

            final stageHeight = lerpDouble(182.0, 228.0, t)!;

            return SizedBox(
              width: stageWidth,
              height: stageHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Analog Clock Squircle (Morphs continuously like sticky notes grid-to-open) ──
                  Positioned(
                    left: dialLeft,
                    top: dialTop,
                    width: dialSize,
                    height: dialSize,
                    child: _SquircleArtworkThumbnail(
                      state: widget.state,
                      minutes: widget.minutes,
                      seconds: widget.seconds,
                      accentColor: widget.accentColor,
                      isDark: widget.isDark,
                      cornerRadius: dialRadius,
                    ),
                  ),

                  // ── Change Color Glass Button (Pinned at top right) ──
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircularGlassButton(
                      size: 40,
                      icon: CupertinoIcons.waveform,
                      iconSize: 18,
                      iconColor: widget.accentColor,
                      isDark: widget.isDark,
                      onTap: widget.onColorTap,
                    ),
                  ),

                  // ── Digital Countdown (Smoothly glides down & scales without flicker) ──
                  Positioned(
                    top: timeTop,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.minutes,
                            style: TextStyle(
                              color: widget.isDark
                                  ? const Color(0xFFF5F5F7)
                                  : const Color(0xFF1C1C1E),
                              fontSize: digitsFontSize,
                              fontWeight: FontWeight.w800,
                              letterSpacing: letterSpacing,
                              height: 1.0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              ':',
                              style: TextStyle(
                                color: widget.isDark
                                    ? Colors.white.withValues(alpha: 0.40)
                                    : Colors.black.withValues(alpha: 0.35),
                                fontSize: colonFontSize,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                          ),
                          Text(
                            widget.seconds,
                            style: TextStyle(
                              color: widget.isDark
                                  ? const Color(0xFFF5F5F7)
                                  : const Color(0xFF1C1C1E),
                              fontSize: digitsFontSize,
                              fontWeight: FontWeight.w800,
                              letterSpacing: letterSpacing,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Squircle Dial Tick Thumbnail (Top Left Artwork / Center Dial) ───────────

class _SquircleArtworkThumbnail extends StatelessWidget {
  final FocusState state;
  final String minutes;
  final String seconds;
  final Color accentColor;
  final bool isDark;
  final double cornerRadius;

  const _SquircleArtworkThumbnail({
    required this.state,
    required this.minutes,
    required this.seconds,
    required this.accentColor,
    required this.isDark,
    this.cornerRadius = 26.0,
  });

  @override
  Widget build(BuildContext context) {
    final radius = cornerRadius;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121214) : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(radius), // continuous squircle
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: state.isRunning ? 0.20 : 0.05),
            blurRadius: 20,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Perimeter Dial Tick Marks & Real Working Clock Hands
          Positioned.fill(
            child: CustomPaint(
              painter: SquircleTickPainter(
                progress: state.progress,
                activeColor: accentColor,
                inactiveColor: isDark
                    ? Colors.white.withValues(alpha: 0.22)
                    : Colors.black.withValues(alpha: 0.18),
                tickCount: 60,
                remainingSeconds: state.remainingSeconds,
                totalSeconds: state.totalSeconds,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Player Icon Button (Back / Skip) ────────────────────────────────────────

class _PlayerIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool isDark;
  final VoidCallback onTap;

  const _PlayerIconButton({
    required this.icon,
    required this.size,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          size: size,
          color: isDark ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF1C1C1E),
        ),
      ),
    );
  }
}

// ─── Big Liquid Glass Play / Pause Button ────────────────────────────────────

class _PlayerGlassPlayPause extends StatelessWidget {
  final bool isRunning;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  const _PlayerGlassPlayPause({
    required this.isRunning,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CircularGlassButton(
      size: 68,
      icon: isRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
      iconSize: 28,
      isDark: isDark,
      onTap: onTap,
    );
  }
}

