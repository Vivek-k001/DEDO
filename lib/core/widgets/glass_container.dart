import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';

/// The foundational glass widget — wraps any child in a frosted-glass surface.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double? blur;
  final double? fillOpacity;
  final double? borderOpacity;
  final Color? tintColor;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final bool showBorder;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = GlassTheme.radiusMedium,
    this.blur,
    this.fillOpacity,
    this.borderOpacity,
    this.tintColor,
    this.shadows,
    this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = GlassTheme.cardBg(isDark);

    final Color effectiveBg = tintColor != null
        ? tintColor!.withValues(alpha: fillOpacity ?? (isDark ? 0.22 : 0.14))
        : (fillOpacity != null
            ? (isDark
                ? Colors.white.withValues(alpha: fillOpacity!)
                : Colors.white.withValues(alpha: fillOpacity!))
            : defaultBg);

    final radius = BorderRadius.circular(borderRadius);

    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: radius,
        border: showBorder
            ? Border.all(
                color: GlassTheme.borderColor(isDark).withValues(alpha: borderOpacity ?? (isDark ? 0.7 : 0.8)),
                width: 0.8,
              )
            : null,
        boxShadow: shadows ?? GlassTheme.glassShadow(isDark),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}
