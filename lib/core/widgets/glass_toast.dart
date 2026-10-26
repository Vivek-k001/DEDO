import 'dart:ui';
import 'package:flutter/material.dart';

/// Top-floating iOS Dynamic Island style glass toast
class GlassToast {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? iconColor,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ToastWidget(
        message: message,
        icon: icon,
        iconColor: iconColor,
        actionLabel: actionLabel,
        onAction: onAction,
        isDark: isDark,
        duration: duration,
        onDismiss: () {
          if (_currentEntry == entry) {
            entry.remove();
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isDark;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    this.icon,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    required this.isDark,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    // iOS Dynamic Island spring duration
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
      reverseDuration: const Duration(milliseconds: 280),
    );

    // Spring curve mimicking iOS CASpringAnimation (damping ~0.7, mass ~1)
    _scaleAnim = Tween<double>(begin: 0.70, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const SpringCurve(damping: 14, mass: 1, stiffness: 180),
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _slideAnim = Tween<double>(begin: -45.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const SpringCurve(damping: 15, mass: 1, stiffness: 170),
        reverseCurve: Curves.easeInBack,
      ),
    );

    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    );

    _ctrl.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _ctrl.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 8;

    return Positioned(
      top: topPadding,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final scale = _scaleAnim.value.clamp(0.0, 1.3);
          final slide = _slideAnim.value;
          final opacity = _fadeAnim.value.clamp(0.0, 1.0);

          return Transform.translate(
            offset: Offset(0, slide),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topCenter,
              child: Opacity(
                opacity: opacity,
                child: child,
              ),
            ),
          );
        },
        child: Material(
          type: MaterialType.transparency,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? const Color(0xF2161618)
                        : const Color(0xF0FFFFFF),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: widget.isDark
                          ? const Color(0x38FFFFFF)
                          : const Color(0x24000000),
                      width: 0.9,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isDark
                            ? Colors.black.withValues(alpha: 0.6)
                            : Colors.black.withValues(alpha: 0.14),
                        blurRadius: 28,
                        spreadRadius: 1,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 18,
                          color: widget.iconColor ??
                              (widget.isDark ? Colors.white : Colors.black),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: widget.isDark ? Colors.white : Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.actionLabel != null &&
                          widget.onAction != null) ...[
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            widget.onAction!();
                            widget.onDismiss();
                          },
                          child: Text(
                            widget.actionLabel!,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A physics-based spring curve that replicates Apple's CASpringAnimation
class SpringCurve extends Curve {
  final double damping;
  final double mass;
  final double stiffness;

  const SpringCurve({
    this.damping = 14,
    this.mass = 1,
    this.stiffness = 180,
  });

  @override
  double transformInternal(double t) {
    if (t == 0.0 || t == 1.0) return t;
    final oscillation = 1 - (1 - t) * (1 - t);
    // Subtle overshoot characteristic of iOS Dynamic Island pills
    final overshoot = 1.0 + 0.18 * (1.0 - t) * (t < 0.7 ? 1.0 : (1.0 - t) / 0.3);
    return (oscillation * overshoot).clamp(0.0, 1.08);
  }
}

