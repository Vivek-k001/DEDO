import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Global glass design tokens — single source of truth for all glass surfaces.
class GlassTheme {
  GlassTheme._();

  // ─── iOS Colors & Tokens ──────────────────────────────────────────────────
  static const Color iosBlue = CupertinoColors.systemBlue;
  static const Color iosIndigo = CupertinoColors.systemIndigo;
  static const Color iosGreen = CupertinoColors.systemGreen;
  static const Color iosOrange = CupertinoColors.systemOrange;
  static const Color iosRed = CupertinoColors.systemRed;
  static const Color iosPurple = CupertinoColors.systemPurple;
  static const Color iosTeal = CupertinoColors.systemTeal;

  // iOS Backgrounds
  static const Color iosLightBg = Color(0xFFF2F2F7); // iOS grouped background
  static const Color iosLightCard = Colors.white;
  static const Color iosLightSecondary = Color(0xFFE5E5EA);

  static const Color iosDarkBg = Color(0xFF000000); // iOS dark true black / OLED
  static const Color iosDarkCard = Color(0xFF1C1C1E); // iOS secondary grouped bg
  static const Color iosDarkSecondary = Color(0xFF2C2C2E);

  // ─── Border & Corner Radii ────────────────────────────────────────────────
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 22.0;
  static const double radiusXL = 28.0;

  // ─── Accents ──────────────────────────────────────────────────────────────
  static const Color accentPrimary = Color(0xFF007AFF); // Apple system blue
  static const Color accentSecondary = Color(0xFF5856D6); // Apple indigo
  static const Color accentSuccess = Color(0xFF34C759); // Apple system green
  static const Color accentWarning = Color(0xFFFF9500); // Apple system orange
  static const Color accentDanger = Color(0xFFFF3B30); // Apple system red

  static const List<Color> accentPresets = [
    Color(0xFF007AFF), // iOS Blue
    Color(0xFF5856D6), // Electric Indigo
    Color(0xFFAF52DE), // Royal Violet
    Color(0xFF34C759), // Emerald
    Color(0xFFFF9500), // Sunset Amber
    Color(0xFFFF2D55), // Coral Pink
    Color(0xFF00C7BE), // Teal
  ];

  // ─── Helpers ──────────────────────────────────────────────────────────────
  static Color cardBg(bool isDark) => isDark ? iosDarkCard : iosLightCard;

  static Color scaffoldBg(bool isDark) => isDark ? iosDarkBg : iosLightBg;

  static Color borderColor(bool isDark) =>
      isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);

  static List<Color> backgroundGradient(bool isDark) =>
      isDark ? [iosDarkBg, iosDarkBg] : [iosLightBg, iosLightBg];

  static List<BoxShadow> glassShadow(bool isDark) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          spreadRadius: 0,
          offset: const Offset(0, 2),
        ),
      ];
}
