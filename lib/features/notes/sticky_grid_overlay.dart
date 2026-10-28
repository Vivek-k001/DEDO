import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
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
        barrierColor: isDark
            ? Colors.black.withValues(alpha: 0.65)
            : const Color(0xFFF2F2F7).withValues(alpha: 0.75),
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (ctx, anim, secondaryAnim) => StickyGridOverlay(isDark: isDark),
        transitionsBuilder: (ctx, anim, secondaryAnim, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // iOS Frosted Glass Blur Backdrop
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              color: widget.isDark
                  ? Colors.black.withValues(alpha: 0.65)
                  : Colors.white.withValues(alpha: 0.45),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      // iOS Bold Header
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFCC00),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Text(
                            'Sticky Notes',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                              fontFamily: '.SF Pro Display',
                              color: widget.isDark
                                  ? Colors.white
                                  : const Color(0xFF111111),
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
                      const SizedBox(width: 12),

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

                // 3x3 Grid or Empty State
                Expanded(
                  child: notes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: widget.isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.04),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  CupertinoIcons.square_pencil,
                                  size: 42,
                                  color: widget.isDark
                                      ? Colors.white.withValues(alpha: 0.45)
                                      : Colors.black.withValues(alpha: 0.35),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Sticky Notes Yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  color: widget.isDark
                                      ? Colors.white.withValues(alpha: 0.85)
                                      : Colors.black.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Pin your quick thoughts and ideas',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: widget.isDark
                                      ? Colors.white.withValues(alpha: 0.45)
                                      : Colors.black.withValues(alpha: 0.4),
                                ),
                              ),
                              const SizedBox(height: 20),
                              CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 11,
                                ),
                                color: const Color(0xFFFF9500),
                                borderRadius: BorderRadius.circular(22),
                                onPressed: _addNewNote,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(CupertinoIcons.add, size: 16, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      'New Sticky',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : _ReorderableStickyGrid(
                          notes: notes,
                          staggerCtrl: _staggerCtrl,
                          onTapNote: _openNoteEditor,
                          onTornNote: (note) async {
                            HapticFeedback.heavyImpact();
                            await ref
                                .read(stickyNoteProvider.notifier)
                                .deleteNote(note.id);
                          },
                          onReorder: (oldIndex, newIndex) async {
                            HapticFeedback.mediumImpact();
                            await ref
                                .read(stickyNoteProvider.notifier)
                                .reorderNotes(oldIndex, newIndex);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── iOS Reorderable Sticky Grid ─────────────────────────────────────────────

class _ReorderableStickyGrid extends StatefulWidget {
  final List<StickyNote> notes;
  final AnimationController staggerCtrl;
  final ValueChanged<StickyNote> onTapNote;
  final ValueChanged<StickyNote> onTornNote;
  final void Function(int oldIndex, int newIndex) onReorder;

  const _ReorderableStickyGrid({
    required this.notes,
    required this.staggerCtrl,
    required this.onTapNote,
    required this.onTornNote,
    required this.onReorder,
  });

  @override
  State<_ReorderableStickyGrid> createState() => _ReorderableStickyGridState();
}

class _ReorderableStickyGridState extends State<_ReorderableStickyGrid>
    with SingleTickerProviderStateMixin {
  late List<StickyNote> _items;

  // Drag state
  int? _draggingIndex;
  int? _pointerDownIndex;
  Offset _pointerDownGlobal = Offset.zero;
  Offset _dragGlobalPos = Offset.zero;
  Offset _touchOffsetInCard = Offset.zero;
  int? _targetHoverIndex;
  bool _holdTriggered = false;
  Timer? _holdTimer;
  int? _activePointerId;

  // Grid layout (set during build)
  double _cardWidth = 0;
  double _cardHeight = 0;
  double _spacingX = 0;
  double _spacingY = 0;
  double _paddingLeft = 0;
  double _paddingTop = 0;
  final GlobalKey _stackKey = GlobalKey();

  // iOS Spring jiggle controller while holding
  late final AnimationController _jiggleCtrl;

  @override
  void initState() {
    super.initState();
    _items = List<StickyNote>.from(widget.notes);
    _jiggleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
  }

  @override
  void didUpdateWidget(covariant _ReorderableStickyGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_draggingIndex == null) {
      _items = List<StickyNote>.from(widget.notes);
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _jiggleCtrl.dispose();
    super.dispose();
  }

  // ── Raw pointer events from each card ────────────────────────────────────────

  void _onCardPointerDown(int index, PointerDownEvent event) {
    _holdTimer?.cancel();
    _pointerDownIndex = index;
    _activePointerId = event.pointer;
    _pointerDownGlobal = event.position;
    _dragGlobalPos = event.position;
    _holdTriggered = false;

    _holdTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted || _pointerDownIndex != index) return;
      if (_holdTriggered) return;
      // Check the pointer hasn't moved too much (not a swipe)
      final dist = (_dragGlobalPos - _pointerDownGlobal).distance;
      if (dist > 12) return;

      _holdTriggered = true;
      _startDrag(index, event.position);
    });
  }

  void _onCardPointerMove(int index, PointerMoveEvent event) {
    if (event.pointer != _activePointerId) return;
    _dragGlobalPos = event.position;

    // If moved too much before hold triggers, cancel the timer
    if (!_holdTriggered && _holdTimer != null) {
      final dist = (event.position - _pointerDownGlobal).distance;
      if (dist > 12) {
        _holdTimer?.cancel();
        _holdTimer = null;
        _pointerDownIndex = null;
      }
    }

    if (_draggingIndex == null) return;
    _updateDragPosition(event.position);
  }

  void _onCardPointerUp(int index, PointerUpEvent event) {
    if (event.pointer != _activePointerId) return;
    _holdTimer?.cancel();
    _holdTimer = null;
    _pointerDownIndex = null;
    _activePointerId = null;
    if (_draggingIndex != null) {
      _endDrag();
    }
  }

  void _onCardPointerCancel(int index, PointerCancelEvent event) {
    _holdTimer?.cancel();
    _holdTimer = null;
    _pointerDownIndex = null;
    _activePointerId = null;
    if (_draggingIndex != null) {
      _endDrag();
    }
  }

  // ── Drag lifecycle ────────────────────────────────────────────────────────────

  void _startDrag(int index, Offset globalPos) {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final localPos = stackBox != null
        ? stackBox.globalToLocal(globalPos)
        : globalPos;

    final col = index % 3;
    final row = index ~/ 3;
    final slotLeft = _paddingLeft + col * (_cardWidth + _spacingX);
    final slotTop = _paddingTop + row * (_cardHeight + _spacingY);

    HapticFeedback.heavyImpact();
    setState(() {
      _draggingIndex = index;
      _targetHoverIndex = index;
      _dragGlobalPos = globalPos;
      _touchOffsetInCard = Offset(localPos.dx - slotLeft, localPos.dy - slotTop);
    });
    _jiggleCtrl.repeat(reverse: true);
  }

  void _updateDragPosition(Offset globalPos) {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final localPos = stackBox != null
        ? stackBox.globalToLocal(globalPos)
        : globalPos;

    setState(() {
      _dragGlobalPos = globalPos;
    });

    // Determine which grid slot the card center is hovering over
    final centerX = localPos.dx - _touchOffsetInCard.dx + _cardWidth / 2;
    final centerY = localPos.dy - _touchOffsetInCard.dy + _cardHeight / 2;

    final clampedX = (centerX - _paddingLeft).clamp(0.0, _cardWidth * 3 + _spacingX * 2);
    final clampedY = (centerY - _paddingTop).clamp(0.0, 99999.0);

    final col = (clampedX / (_cardWidth + _spacingX)).floor().clamp(0, 2);
    final row = (clampedY / (_cardHeight + _spacingY)).floor();
    final hoveredIndex = (row * 3 + col).clamp(0, _items.length - 1);

    if (hoveredIndex != _targetHoverIndex) {
      HapticFeedback.selectionClick();
      setState(() {
        final item = _items.removeAt(_draggingIndex!);
        _items.insert(hoveredIndex, item);
        _draggingIndex = hoveredIndex;
        _targetHoverIndex = hoveredIndex;
      });
    }
  }

  void _endDrag() {
    final finalIndex = _draggingIndex!;
    final originalIndex = widget.notes.indexWhere((n) => n.id == _items[finalIndex].id);

    HapticFeedback.mediumImpact();
    _jiggleCtrl.stop();
    _jiggleCtrl.reset();
    _holdTriggered = false;

    setState(() {
      _draggingIndex = null;
      _targetHoverIndex = null;
    });

    if (originalIndex != -1 && originalIndex != finalIndex) {
      widget.onReorder(originalIndex, finalIndex);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _paddingLeft = 16.0;
        _paddingTop = 8.0;
        const paddingRight = 16.0;
        _spacingX = 12.0;
        _spacingY = 14.0;
        const crossAxisCount = 3;

        final availableWidth = constraints.maxWidth - _paddingLeft - paddingRight;
        _cardWidth = (availableWidth - (_spacingX * (crossAxisCount - 1))) / crossAxisCount;
        _cardHeight = _cardWidth / 0.88;

        final totalRows = ((_items.length + crossAxisCount - 1) / crossAxisCount).ceil();
        final contentHeight = _paddingTop + (totalRows * _cardHeight) + ((totalRows - 1).clamp(0, 999) * _spacingY) + 32.0;

        return SingleChildScrollView(
          physics: _draggingIndex != null
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          child: SizedBox(
            height: contentHeight > constraints.maxHeight ? contentHeight : constraints.maxHeight,
            child: Stack(
              key: _stackKey,
              clipBehavior: Clip.none,
              children: [
                // Placed cards
                for (int i = 0; i < _items.length; i++)
                  if (i != _draggingIndex)
                    _buildCardSlot(i, _items[i]),

                // Floating lifted card
                if (_draggingIndex != null && _draggingIndex! < _items.length)
                  _buildFloatingCard(_items[_draggingIndex!]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardSlot(int index, StickyNote note) {
    final col = index % 3;
    final row = index ~/ 3;
    final left = _paddingLeft + col * (_cardWidth + _spacingX);
    final top = _paddingTop + row * (_cardHeight + _spacingY);

    final startTime = (index * 0.05).clamp(0.0, 0.7);
    final endTime = (startTime + 0.3).clamp(0.0, 1.0);
    final itemAnim = CurvedAnimation(
      parent: widget.staggerCtrl,
      curve: Interval(startTime, endTime, curve: const SpringCurve()),
    );

    return AnimatedPositioned(
      key: ValueKey(note.id),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      left: left,
      top: top,
      width: _cardWidth,
      height: _cardHeight,
      child: AnimatedBuilder(
        animation: itemAnim,
        builder: (ctx, child) => Opacity(
          opacity: itemAnim.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - itemAnim.value) * 36),
            child: child,
          ),
        ),
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) => _onCardPointerDown(index, e),
          onPointerMove: (e) => _onCardPointerMove(index, e),
          onPointerUp: (e) => _onCardPointerUp(index, e),
          onPointerCancel: (e) => _onCardPointerCancel(index, e),
          child: _TearableStickyNoteCard(
            key: ValueKey('card_${note.id}'),
            note: note,
            isReorderingActive: _draggingIndex != null,
            onTap: () => widget.onTapNote(note),
            onTorn: () => widget.onTornNote(note),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCard(StickyNote note) {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final localPos = stackBox != null
        ? stackBox.globalToLocal(_dragGlobalPos)
        : _dragGlobalPos;

    final x = localPos.dx - _touchOffsetInCard.dx;
    final y = localPos.dy - _touchOffsetInCard.dy;

    return Positioned(
      left: x,
      top: y,
      width: _cardWidth,
      height: _cardHeight,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _jiggleCtrl,
          builder: (ctx, child) {
            final wobble = (_jiggleCtrl.value - 0.5) * 0.06;
            return Transform.rotate(
              angle: wobble,
              child: Transform.scale(
                scale: 1.1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.38),
                        blurRadius: 24,
                        spreadRadius: 3,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: _TearableStickyNoteCard(
            key: ValueKey('lifted_${note.id}'),
            note: note,
            onTap: () {},
            onTorn: () {},
            isLifted: true,
          ),
        ),
      ),
    );
  }
}

// ─── Tearable Sticky Card (Swipe-to-Tear) ────────────────────────────────────

class _TearableStickyNoteCard extends StatefulWidget {
  final StickyNote note;
  final VoidCallback onTap;
  final VoidCallback onTorn;
  final bool isLifted;
  final bool isReorderingActive;

  const _TearableStickyNoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onTorn,
    this.isLifted = false,
    this.isReorderingActive = false,
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
    if (_isTearing || widget.isLifted || widget.isReorderingActive) return;
    setState(() {
      _dragOffset += details.primaryDelta ?? 0;
    });

    if (_dragOffset.abs() > 40 && _dragOffset.abs() < 45) {
      HapticFeedback.selectionClick();
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isTearing || widget.isLifted || widget.isReorderingActive) return;
    const threshold = 65.0;

    if (_dragOffset.abs() > threshold) {
      setState(() => _isTearing = true);
      HapticFeedback.heavyImpact();
      _tearAnim.forward().then((_) {
        widget.onTorn();
      });
    } else {
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
      onTap: widget.isLifted || widget.isReorderingActive ? null : widget.onTap,
      onHorizontalDragUpdate: widget.isReorderingActive ? null : _onHorizontalDragUpdate,
      onHorizontalDragEnd: widget.isReorderingActive ? null : _onHorizontalDragEnd,
      child: AnimatedBuilder(
        animation: _tearAnim,
        builder: (context, child) {
          final tearProgress = _tearAnim.value;
          final currentDx = _dragOffset +
              (_tearAnim.isAnimating
                  ? (_dragOffset > 0 ? 120 : -120) * tearProgress
                  : 0);
          final tearRotation = rotation +
              (_dragOffset * 0.0018) +
              (tearProgress * (_dragOffset > 0 ? 0.35 : -0.35));
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
        child: Hero(
          tag: 'sticky_hero_${widget.note.id}',
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Subtle top adhesive strip highlight
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 18,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.06),
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                    ),
                  ),

                  // Content Preview
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 22, 10, 8),
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
                            overflow: TextOverflow.clip,
                          ),
                        ),
                        if (widget.note.content.trim().length > 40 ||
                            widget.note.content.trim().contains('\n'))
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '• • •',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                    height: 1.0,
                                    color: Colors.black.withValues(alpha: 0.45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Dashed Perforated Tear Line with Gliding Scissors
                  if (_dragOffset.abs() > 6 || _isTearing)
                    Positioned(
                      top: 14,
                      left: 6,
                      right: 6,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerLeft,
                        children: [
                          Row(
                            children: List.generate(
                              12,
                              (i) => Expanded(
                                child: Container(
                                  height: 1.5,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 1.5),
                                  color: Colors.black.withValues(
                                    alpha:
                                        (_dragOffset.abs() / 50).clamp(0.2, 0.65),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
        ),
      ),
    );
  }
}

// ─── Sticky Detail Modal (Hero Zoom directly to/from grid card) ───────────────

class _StickyDetailModal extends StatefulWidget {
  final StickyNote note;
  final bool isDark;

  const _StickyDetailModal({
    required this.note,
    required this.isDark,
  });

  static Future<void> show(
    BuildContext context, {
    required StickyNote note,
    required bool isDark,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.transparent, // Handled with BackdropFilter
        transitionDuration: const Duration(milliseconds: 360),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (ctx, anim, secondaryAnim) =>
            _StickyDetailModal(note: note, isDark: isDark),
        transitionsBuilder: (ctx, anim, secondaryAnim, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: anim,
              curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
            ),
            child: child,
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
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note.content);
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isEditing = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _saveAndClose() {
    _focusNode.unfocus();
    HapticFeedback.selectionClick();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.note.colorValue);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false, // Prevents keyboard from squishing/distorting the note!
      body: Stack(
        fit: StackFit.expand,
        children: [
          // iOS Frosted Blur Backdrop
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              color: Colors.black.withValues(alpha: widget.isDark ? 0.65 : 0.45),
            ),
          ),

          // Tap Outside Area to save and dismiss back to grid
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _saveAndClose,
            child: const SizedBox.expand(),
          ),

          // Note Card Morphing from/to its exact Grid Slot via Hero
          AnimatedPositioned(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            left: 24,
            right: 24,
            // When editing, smoothly float the note upward so keyboard doesn't cover it
            bottom: bottomInset > 0
                ? (bottomInset + 20)
                : (MediaQuery.of(context).size.height - 380) / 2,
            child: Consumer(
              builder: (context, ref, child) {
                return Hero(
                  tag: 'sticky_hero_${widget.note.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      height: 340,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top sticky strip with check mark
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.08),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isEditing
                                            ? CupertinoIcons.pencil_circle_fill
                                            : CupertinoIcons.doc_text_fill,
                                        size: 15,
                                        color: Colors.black.withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          _isEditing ? 'Editing Note' : 'Quick Note',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: '.SF Pro Text',
                                            color: Colors.black.withValues(alpha: 0.65),
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _saveAndClose,
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

                          // Editor (with right-side scrollbar for tracking note length)
                          Expanded(
                            child: RawScrollbar(
                              controller: _scrollController,
                              thumbVisibility: true,
                              thickness: 4.0,
                              radius: const Radius.circular(4),
                              thumbColor: Colors.black.withValues(alpha: 0.28),
                              crossAxisMargin: 4.0,
                              mainAxisMargin: 10.0,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(18, 14, 18, 16),
                                child: TextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  scrollController: _scrollController,
                                  autofocus: false, // Read first! Buttery smooth Hero
                                  showCursor: true,
                                  cursorColor: Colors.black87,
                                  cursorWidth: 2.2,
                                  cursorRadius: const Radius.circular(2),
                                  maxLines: null,
                                  expands: true,
                                  onTap: () {
                                    // User tapped inside to edit
                                    if (!_focusNode.hasFocus) {
                                      HapticFeedback.lightImpact();
                                    }
                                  },
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
                                    hintText: 'Tap to type your thoughts...',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black.withValues(alpha: 0.35),
                                    ),
                                    border: InputBorder.none,
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── iOS 27 Liquid Glass Icon Button ─────────────────────────────────────────
// Implements Apple's Liquid Glass design: layered glass sphere with
// specular top-edge highlight, soft depth shadow, and physical press scale.

class _IosIconButton extends StatefulWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _IosIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_IosIconButton> createState() => _IosIconButtonState();
}

class _IosIconButtonState extends State<_IosIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.86).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.lightImpact();
    _pressCtrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _pressCtrl.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Layer 1: Depth shadow (physical elevation) ──
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.45)
                          : Colors.black.withValues(alpha: 0.16),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.22)
                          : Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),

              // ── Layer 2: Glass base with circular refractive body & blur ──
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.25, -0.35),
                        radius: 0.95,
                        colors: isDark
                            ? [
                                Colors.white.withValues(alpha: 0.18),
                                Colors.white.withValues(alpha: 0.05),
                                Colors.black.withValues(alpha: 0.28),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.92),
                                Colors.white.withValues(alpha: 0.55),
                                Colors.white.withValues(alpha: 0.32),
                              ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Layer 3: Circular Rim Light ──
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CircularGlassRimPainter(isDark: isDark),
                  ),
                ),
              ),

              // ── Layer 4: Icon (bold glyph) ──
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 20,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.98)
                        : const Color(0xFF111111),
                    shadows: [
                      Shadow(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.black.withValues(alpha: 0.7),
                        blurRadius: 1.2,
                      ),
                      Shadow(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.5),
                        blurRadius: 0.6,
                      ),
                    ],
                  ),
                  Icon(
                    widget.icon,
                    size: 20,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.98)
                        : const Color(0xFF111111),
                  ),
                ],
              ),
            ],
          ),
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
    return -math.pow(math.e, -7 * t) * math.cos(8 * t) + 1;
  }
}

// ─── Circular Liquid Glass Rim Painter ───────────────────────────────────────
// Accurately renders circular rim lighting, top-left specular illumination,
// and bottom bounce reflection based on Apple's Liquid Glass optics.

class _CircularGlassRimPainter extends CustomPainter {
  final bool isDark;

  const _CircularGlassRimPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 1.2) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Full perimeter baseline outline (delicate glass contour)
    final baseOutlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.14)
          : Colors.white.withValues(alpha: 0.45);
    canvas.drawCircle(center, radius, baseOutlinePaint);

    // 2. Dynamic SweepGradient Rim Light
    // Simulates directional light entering from top-left (approx. 225 deg / -3*pi/4)
    // with a primary specular crescent and a subtle bottom bounce
    final rimLightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: math.pi * 2,
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.08),  // Right (shadowed edge)
                Colors.white.withValues(alpha: 0.32),  // Bottom (ambient bounce)
                Colors.white.withValues(alpha: 0.10),  // Bottom-left transition
                Colors.white.withValues(alpha: 0.85),  // Top-left (bright specular rim)
                Colors.white.withValues(alpha: 0.50),  // Top transition
                Colors.white.withValues(alpha: 0.08),  // Right (shadowed edge)
              ]
            : [
                Colors.white.withValues(alpha: 0.25),
                Colors.white.withValues(alpha: 0.60),
                Colors.white.withValues(alpha: 0.30),
                Colors.white.withValues(alpha: 0.98),
                Colors.white.withValues(alpha: 0.70),
                Colors.white.withValues(alpha: 0.25),
              ],
        stops: const [0.0, 0.25, 0.45, 0.68, 0.85, 1.0],
      ).createShader(rect);

    canvas.drawCircle(center, radius, rimLightPaint);
  }

  @override
  bool shouldRepaint(covariant _CircularGlassRimPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

