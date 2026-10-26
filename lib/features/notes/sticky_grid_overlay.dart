import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/sticky_note.dart';
import '../../../providers/sticky_note_provider.dart';

class StickyGridOverlay extends ConsumerStatefulWidget {
  final bool isDark;

  const StickyGridOverlay({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: isDark ? 0.65 : 0.4),
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (ctx, anim, secondaryAnim) => StickyGridOverlay(isDark: isDark),
        transitionsBuilder: (ctx, anim, secondaryAnim, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: const SpringCurve(),
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  ConsumerState<StickyGridOverlay> createState() => _StickyGridOverlayState();
}

class _StickyGridOverlayState extends ConsumerState<StickyGridOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  void _openNoteEditor(StickyNote note) {
    HapticFeedback.selectionClick();
    _StickyDetailModal.show(context, note: note, isDark: widget.isDark);
  }

  Future<void> _addNewNote() async {
    HapticFeedback.mediumImpact();
    final note = await ref.read(stickyNoteProvider.notifier).addNote(content: '');
    if (mounted) {
      _openNoteEditor(note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(stickyNoteProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                children: [
                  // Title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFCC00),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sticky Notes',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: widget.isDark ? Colors.white : const Color(0xFF1A0A2E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to edit • Glide across to tear & trash',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: widget.isDark
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Add button
                  _IosIconButton(
                    icon: CupertinoIcons.add,
                    isDark: widget.isDark,
                    onTap: _addNewNote,
                  ),
                  const SizedBox(width: 10),

                  // Close button
                  _IosIconButton(
                    icon: CupertinoIcons.xmark,
                    isDark: widget.isDark,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),

            // 3x3 Grid of Sticky Notes
            Expanded(
              child: notes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.doc_text_viewfinder,
                            size: 56,
                            color: widget.isDark
                                ? Colors.white.withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No Sticky Notes yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: widget.isDark
                                  ? Colors.white.withValues(alpha: 0.75)
                                  : Colors.black.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap + in the top right to pin your first thought',
                            style: TextStyle(
                              fontSize: 13,
                              color: widget.isDark
                                  ? Colors.white.withValues(alpha: 0.45)
                                  : Colors.black.withValues(alpha: 0.45),
                            ),
                          ),
                          const SizedBox(height: 22),
                          ElevatedButton.icon(
                            onPressed: _addNewNote,
                            icon: const Icon(CupertinoIcons.add, size: 16),
                            label: const Text('Add Sticky Note'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9500),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 3x3 grid line by line
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.88, // Realistic square-ish sticky note ratio
                      ),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];

                        // iOS line-by-line staggered entry animation
                        final startTime = (index * 0.05).clamp(0.0, 0.7);
                        final endTime = (startTime + 0.3).clamp(0.0, 1.0);
                        final itemAnimation = CurvedAnimation(
                          parent: _staggerCtrl,
                          curve: Interval(startTime, endTime, curve: const SpringCurve()),
                        );

                        return AnimatedBuilder(
                          animation: itemAnimation,
                          builder: (context, child) {
                            final dy = (1.0 - itemAnimation.value) * 36;
                            return Opacity(
                              opacity: itemAnimation.value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, dy),
                                child: child,
                              ),
                            );
                          },
                          child: _TearableStickyNoteCard(
                            key: ValueKey(note.id),
                            note: note,
                            onTap: () => _openNoteEditor(note),
                            onTorn: () async {
                              HapticFeedback.heavyImpact();
                              await ref
                                  .read(stickyNoteProvider.notifier)
                                  .deleteNote(note.id);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tearable Sticky Card (Physical Horizontal Glide Tear Animation) ───────────

class _TearableStickyNoteCard extends StatefulWidget {
  final StickyNote note;
  final VoidCallback onTap;
  final VoidCallback onTorn;

  const _TearableStickyNoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onTorn,
  });

  @override
  State<_TearableStickyNoteCard> createState() => _TearableStickyNoteCardState();
}

class _TearableStickyNoteCardState extends State<_TearableStickyNoteCard>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  bool _isTearing = false;

  late final AnimationController _tearAnim;

  @override
  void initState() {
    super.initState();
    _tearAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _tearAnim.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isTearing) return;
    setState(() {
      _dragOffset += details.primaryDelta ?? 0;
    });

    // Provide micro-haptic ticking as resistance builds
    if (_dragOffset.abs() > 40 && _dragOffset.abs() < 45) {
      HapticFeedback.selectionClick();
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isTearing) return;
    final threshold = 65.0; // Horizontal glide distance threshold

    if (_dragOffset.abs() > threshold) {
      // Trigger tear sequence!
      setState(() => _isTearing = true);
      HapticFeedback.heavyImpact();
      _tearAnim.forward().then((_) {
        widget.onTorn();
      });
    } else {
      // Spring back to rest position
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.note.colorValue);
    final rotation = widget.note.rotationAngle;

    return GestureDetector(
      onTap: widget.onTap,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: AnimatedBuilder(
        animation: _tearAnim,
        builder: (context, child) {
          final tearProgress = _tearAnim.value;
          final currentDx = _dragOffset + (_tearAnim.isAnimating ? (_dragOffset > 0 ? 120 : -120) * tearProgress : 0);
          final tearRotation = rotation + (_dragOffset * 0.0018) + (tearProgress * (_dragOffset > 0 ? 0.35 : -0.35));
          final scale = 1.0 - (tearProgress * 0.35);
          final opacity = (1.0 - tearProgress).clamp(0.0, 1.0);

          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(currentDx, tearProgress * 40),
              child: Transform.rotate(
                angle: tearRotation,
                alignment: Alignment.topCenter,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              // Physical sticky note depth shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Realistic top adhesive strip highlight
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 18,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.06),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                ),
              ),

              // Content Preview
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 22, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.note.content.isEmpty
                            ? 'Blank note...'
                            : widget.note.content,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: widget.note.content.isEmpty
                              ? Colors.black.withValues(alpha: 0.35)
                              : Colors.black.withValues(alpha: 0.85),
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Perforated Dashed Tear Line (- - - - -) with Gliding Scissors ───
              if (_dragOffset.abs() > 6 || _isTearing)
                Positioned(
                  top: 14,
                  left: 6,
                  right: 6,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.centerLeft,
                    children: [
                      // Dashed perforation line
                      Row(
                        children: List.generate(
                          12,
                          (i) => Expanded(
                            child: Container(
                              height: 1.5,
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              color: Colors.black.withValues(
                                alpha: (_dragOffset.abs() / 50).clamp(0.2, 0.65),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Animated Gliding Scissors along the tear line
                      Positioned(
                        left: (_dragOffset > 0
                                ? (_dragOffset * 1.1)
                                : (80 + _dragOffset * 1.1))
                            .clamp(0.0, 75.0),
                        top: -9,
                        child: Transform.rotate(
                          angle: _dragOffset > 0 ? 0.2 : -0.2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: const Icon(
                              CupertinoIcons.scissors,
                              size: 11,
                              color: Color(0xFFFF3B30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sticky Detail Modal (Tap to Enlarge & Edit) ──────────────────────────────

class _StickyDetailModal extends StatefulWidget {
  final StickyNote note;
  final bool isDark;

  const _StickyDetailModal({required this.note, required this.isDark});

  static Future<void> show(BuildContext context,
      {required StickyNote note, required bool isDark}) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        transitionDuration: const Duration(milliseconds: 360),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (ctx, anim, secondaryAnim) =>
            _StickyDetailModal(note: note, isDark: isDark),
        transitionsBuilder: (ctx, anim, secondaryAnim, child) {
          final curve = CurvedAnimation(
            parent: anim,
            curve: const SpringCurve(),
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1.0).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  State<_StickyDetailModal> createState() => _StickyDetailModalState();
}

class _StickyDetailModalState extends State<_StickyDetailModal> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.note.colorValue);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Consumer(
            builder: (context, ref, child) {
              return Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 280, maxHeight: 420),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top sticky strip with close button
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.08),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quick Note',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withValues(alpha: 0.65),
                              letterSpacing: -0.2,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.check_mark,
                                size: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Editor
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          maxLines: null,
                          expands: true,
                          onChanged: (val) {
                            ref
                                .read(stickyNoteProvider.notifier)
                                .updateNoteContent(widget.note.id, val);
                          },
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type your thoughts here...',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.black.withValues(alpha: 0.35),
                            ),
                            border: InputBorder.none,
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
      ),
    );
  }
}

// ─── iOS Circular Glass Icon Button ──────────────────────────────────────────

class _IosIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _IosIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDark ? Colors.white : const Color(0xFF1A0A2E),
        ),
      ),
    );
  }
}

// ─── Custom iOS Spring Curve ──────────────────────────────────────────────────

class SpringCurve extends Curve {
  const SpringCurve();

  @override
  double transformInternal(double t) {
    // Physical critically damped spring approximation
    return -math.pow(math.e, -7 * t) * math.cos(8 * t) + 1;
  }
}
