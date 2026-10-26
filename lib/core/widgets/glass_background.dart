import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';

/// Fluid glass background with optional subtle ambient mesh glow
class GlassBackground extends StatelessWidget {
  final Widget child;
  final Color? ambientColor;

  const GlassBackground({super.key, required this.child, this.ambientColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = GlassTheme.scaffoldBg(isDark);
    final glow = ambientColor ?? Theme.of(context).primaryColor;

    return Container(
      color: bg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dynamic liquid ambient aura (top right)
          Positioned(
            top: -100,
            right: -80,
            width: 320,
            height: 320,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      glow.withValues(alpha: isDark ? 0.12 : 0.08),
                      glow.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Dynamic liquid ambient aura (mid left)
          Positioned(
            top: 280,
            left: -120,
            width: 300,
            height: 300,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      glow.withValues(alpha: isDark ? 0.08 : 0.05),
                      glow.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
