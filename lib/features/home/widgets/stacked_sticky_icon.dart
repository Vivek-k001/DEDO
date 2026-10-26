import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/sticky_note_provider.dart';

class StackedStickyIcon extends ConsumerWidget {
  final VoidCallback onTap;
  final bool isDark;

  const StackedStickyIcon({
    super.key,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(stickyNoteProvider);

    // Dynamic top colors based on existing notes or default to vibrant red & yellow
    final topColor = notes.isNotEmpty
        ? Color(notes.first.colorValue)
        : const Color(0xFFFF5A52); // Soft Coral Red
    final middleColor = notes.length > 1
        ? Color(notes[1].colorValue)
        : const Color(0xFFFFCC00); // Soft Sunflower Yellow
    final backColor = notes.length > 2
        ? Color(notes[2].colorValue)
        : const Color(0xFF34C759); // Apple Mint Green

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(left: 6, bottom: 2),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Bottom paper layer (tilted left)
              Transform.rotate(
                angle: -0.16,
                child: Container(
                  width: 21,
                  height: 21,
                  decoration: BoxDecoration(
                    color: backColor,
                    borderRadius: BorderRadius.circular(4.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 3,
                        offset: const Offset(-1, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Middle paper layer (tilted right)
              Transform.rotate(
                angle: 0.14,
                child: Container(
                  width: 21,
                  height: 21,
                  decoration: BoxDecoration(
                    color: middleColor,
                    borderRadius: BorderRadius.circular(4.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Top paper layer (straight with depth & adhesive band)
              Transform.rotate(
                angle: -0.03,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: topColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 5,
                        offset: const Offset(0, 2.5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Mini adhesive strip on top
                      Container(
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.1),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                        ),
                      ),
                      const Spacer(),
                      // Subtle line marks
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        height: 1.5,
                        color: Colors.black.withValues(alpha: 0.12),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 4, right: 8, bottom: 4),
                        height: 1.5,
                        color: Colors.black.withValues(alpha: 0.12),
                      ),
                    ],
                  ),
                ),
              ),

              // Mini count badge if user has notes
              if (notes.isNotEmpty)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Center(
                      child: Text(
                        '${notes.length}',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1A0A2E),
                          height: 1.0,
                        ),
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
