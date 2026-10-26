import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/glass_toast.dart';
import '../../providers/category_provider.dart';
import '../../providers/focus_provider.dart';
import '../../providers/task_provider.dart';
import 'widgets/squircle_tick_painter.dart';

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

                    // Close Button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: isDark ? 0.12 : 0.08),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.xmark,
                          size: 14,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ══════════════════════════════════════════════════════════════
                // ─── MASTER COMPONENT: AUTHENTIC iOS 26 SQUIRCLE PLAYER ───
                // ══════════════════════════════════════════════════════════════
                ClipRRect(
                  borderRadius: BorderRadius.circular(46), // Apple continuous squircle
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(46),
                        // Liquid Glass layered background (no heavy solid gradient)
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.65),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.22)
                              : Colors.white.withValues(alpha: 0.85),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                            blurRadius: 36,
                            offset: const Offset(0, 16),
                          ),
                          BoxShadow(
                            color: taskAccentColor.withValues(
                                alpha: focusState.isRunning ? 0.25 : 0.08),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Top Row: Squircle Thumbnail (Clock 1) or Center Dial Stage (Clock 2) ──
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, anim) => FadeTransition(
                              opacity: anim,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.92, end: 1.0).animate(anim),
                                child: child,
                              ),
                            ),
                            child: focusState.clockStyle == FocusClockStyle.clock1
                                ? Column(
                                    key: const ValueKey('layout_clock1'),
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Left: Squircle Album/Dial Artwork (96x96)
                                          SizedBox(
                                            width: 96,
                                            height: 96,
                                            child: _SquircleArtworkThumbnail(
                                              state: focusState,
                                              minutes: minutes,
                                              seconds: seconds,
                                              accentColor: taskAccentColor,
                                              isDark: isDark,
                                            ),
                                          ),

                                          // Right: AirPlay / Soundwave Glass Button (Cycles theme color)
                                          _AirPlayGlassIndicator(
                                            isRunning: focusState.isRunning,
                                            accentColor: taskAccentColor,
                                            isDark: isDark,
                                            onTap: () {
                                              HapticFeedback.selectionClick();
                                              focusNotifier.cycleColor();
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      // Clock 1 Digital Face
                                      _Clock1Display(
                                        minutes: minutes,
                                        seconds: seconds,
                                        isRunning: focusState.isRunning,
                                        accentColor: taskAccentColor,
                                        isDark: isDark,
                                      ),
                                    ],
                                  )
                                : Column(
                                    key: const ValueKey('layout_clock2'),
                                    children: [
                                      // Top mini bar: color toggle on right
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: _AirPlayGlassIndicator(
                                          isRunning: focusState.isRunning,
                                          accentColor: taskAccentColor,
                                          isDark: isDark,
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            focusNotifier.cycleColor();
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Big Centered Fluid Squircle Dial Clock (148x148)
                                      Center(
                                        child: SizedBox(
                                          width: 148,
                                          height: 148,
                                          child: _SquircleArtworkThumbnail(
                                            state: focusState,
                                            minutes: minutes,
                                            seconds: seconds,
                                            accentColor: taskAccentColor,
                                            isDark: isDark,
                                            isLargeCenter: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      // Digital countdown sits gracefully below the expanded center dial
                                      SizedBox(
                                        height: 52,
                                        width: double.infinity,
                                        child: _Clock2Display(
                                          minutes: minutes,
                                          seconds: seconds,
                                          isRunning: focusState.isRunning,
                                          accentColor: taskAccentColor,
                                          isDark: isDark,
                                        ),
                                      ),
                                    ],
                                  ),
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
                                GestureDetector(
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
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: activeTask.isCompleted
                                          ? const Color(0xFF34C759).withValues(alpha: 0.2)
                                          : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.checkmark_alt,
                                      size: 18,
                                      color: activeTask.isCompleted
                                          ? const Color(0xFF34C759)
                                          : (isDark ? Colors.white54 : Colors.black45),
                                    ),
                                  ),
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
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          focusNotifier.setDuration(mins);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? taskAccentColor
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.white.withValues(alpha: 0.6)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isCurrent
                                  ? taskAccentColor
                                  : (isDark ? Colors.white12 : Colors.black12),
                            ),
                          ),
                          child: Text(
                            '${mins}m',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isCurrent
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
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

// ─── Sliding Glass Capsule (Clock 1 vs Clock 2) ──────────────────────────────

class _SlidingClockPill extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.09)
            : Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pillOption(
            title: 'Clock 1',
            isSelected: clockStyle == FocusClockStyle.clock1,
            onTap: () => onSelect(FocusClockStyle.clock1),
          ),
          _pillOption(
            title: 'Clock 2',
            isSelected: clockStyle == FocusClockStyle.clock2,
            onTap: () => onSelect(FocusClockStyle.clock2),
          ),
        ],
      ),
    );
  }

  Widget _pillOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : Colors.black)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? Colors.white60 : Colors.black54),
          ),
        ),
      ),
    );
  }
}

// ─── Squircle Dial Tick Thumbnail (Top Left Artwork) ─────────────────────────

class _SquircleArtworkThumbnail extends StatelessWidget {
  final FocusState state;
  final String minutes;
  final String seconds;
  final Color accentColor;
  final bool isDark;
  final bool isLargeCenter;

  const _SquircleArtworkThumbnail({
    required this.state,
    required this.minutes,
    required this.seconds,
    required this.accentColor,
    required this.isDark,
    this.isLargeCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = isLargeCenter ? 38.0 : 26.0;
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

// ─── AirPlay / Audio Router Indicator (Top Right of Squircle Player) ─────────

class _AirPlayGlassIndicator extends StatelessWidget {
  final bool isRunning;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  const _AirPlayGlassIndicator({
    required this.isRunning,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (isDark ? Colors.white : Colors.black)
              .withValues(alpha: isDark ? 0.09 : 0.05),
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.2),
            width: 0.8,
          ),
        ),
        child: Center(
          child: Icon(
            CupertinoIcons.waveform,
            size: 20,
            color: isRunning ? accentColor : (isDark ? Colors.white60 : Colors.black45),
          ),
        ),
      ),
    );
  }
}

// ─── Clock 1: Modern Digital Dial Face (Exact 100px Height) ──────────────────

class _Clock1Display extends StatelessWidget {
  final String minutes;
  final String seconds;
  final bool isRunning;
  final Color accentColor;
  final bool isDark;

  const _Clock1Display({
    required this.minutes,
    required this.seconds,
    required this.isRunning,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                minutes,
                style: TextStyle(
                  color: isDark ? const Color(0xFFF5F5F7) : const Color(0xFF1C1C1E),
                  fontSize: 58,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2.0,
                  height: 1.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  ':',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.40)
                        : Colors.black.withValues(alpha: 0.35),
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
              Text(
                seconds,
                style: TextStyle(
                  color: isDark ? const Color(0xFFF5F5F7) : const Color(0xFF1C1C1E),
                  fontSize: 58,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2.0,
                  height: 1.0,
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}

// ─── Clock 2: iOS Lockscreen Rounded Display (Exact Same Baseline & Height) ─

class _Clock2Display extends StatelessWidget {
  final String minutes;
  final String seconds;
  final bool isRunning;
  final Color accentColor;
  final bool isDark;

  const _Clock2Display({
    required this.minutes,
    required this.seconds,
    required this.isRunning,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                minutes,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  ':',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.40)
                        : Colors.black.withValues(alpha: 0.35),
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
              Text(
                seconds,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
            ],
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

class _PlayerGlassPlayPause extends StatefulWidget {
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
  State<_PlayerGlassPlayPause> createState() => _PlayerGlassPlayPauseState();
}

class _PlayerGlassPlayPauseState extends State<_PlayerGlassPlayPause> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isRunning = widget.isRunning;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.08),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.35 : 0.60),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: isRunning ? 0.35 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              isRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
              size: 30,
              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
            ),
          ),
        ),
      ),
    );
  }
}

