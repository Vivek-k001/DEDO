import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../core/widgets/glass_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/circular_glass_button.dart';
import '../../../core/widgets/fluent_liquid_glass_button.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/ios_glass_blue_button.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../../models/track_list.dart';
import '../../../models/track_item.dart';
import '../../../providers/track_list_provider.dart';
import '../../../providers/theme_provider.dart';
import 'create_track_list_screen.dart';

enum TrackListFilter { all, completed, pending }

class TrackListDetailScreen extends ConsumerStatefulWidget {
  final String trackerId;

  const TrackListDetailScreen({super.key, required this.trackerId});

  @override
  ConsumerState<TrackListDetailScreen> createState() =>
      _TrackListDetailScreenState();
}

class _TrackListDetailScreenState
    extends ConsumerState<TrackListDetailScreen> {
  TrackListFilter _filter = TrackListFilter.all;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddEntryModal(TrackList tracker, bool isDark, {bool initialAllInOne = false}) {
    bool isAllInOne = initialAllInOne;
    final singleNameCtrl = TextEditingController();
    final singleNoteCtrl = TextEditingController();
    final bulkNamesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + "Add Multiple" Pill / Action + Close Icon
                  Row(
                    children: [
                      Text(
                        isAllInOne ? 'Add Multiple Entries' : 'Add Entry',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1A0A2E),
                        ),
                      ),
                      const Spacer(),
                      // Toggle action button right next to the close button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setModalState(() => isAllInOne = !isAllInOne);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isAllInOne
                                ? GlassTheme.accentPrimary
                                    .withValues(alpha: isDark ? 0.3 : 0.15)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.06)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isAllInOne
                                  ? GlassTheme.accentPrimary
                                  : (isDark
                                      ? const Color(0xFF38383A)
                                      : const Color(0xFFE5E5EA)),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isAllInOne
                                    ? CupertinoIcons.person
                                    : CupertinoIcons.person_3_fill,
                                size: 14,
                                color: isAllInOne
                                    ? GlassTheme.accentPrimary
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isAllInOne ? 'One by one' : 'Add multiple',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isAllInOne
                                      ? GlassTheme.accentPrimary
                                      : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Icon(
                          CupertinoIcons.clear_circled_solid,
                          color: isDark ? Colors.white38 : Colors.black38,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Mode 1: All In One (Multiple Entries via Enter)
                  if (isAllInOne) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Separate by Enter, comma (,), or use + Line:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            final cur = bulkNamesCtrl.text;
                            if (cur.isNotEmpty && !cur.endsWith("\n")) {
                              bulkNamesCtrl.text = cur + "\n";
                            }
                            bulkNamesCtrl.selection = TextSelection.fromPosition(
                              TextPosition(offset: bulkNamesCtrl.text.length),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: GlassTheme.accentPrimary
                                  .withValues(alpha: isDark ? 0.25 : 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.return_icon,
                                  size: 13,
                                  color: GlassTheme.accentPrimary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '+ New Line',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: GlassTheme.accentPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GlassTextField(
                      label: 'Names List',
                      hint: 'John Doe, Alice Smith, Bob (or newline)...',
                      controller: bulkNamesCtrl,
                      maxLines: 7,
                      keyboardType: TextInputType.multiline,
                      prefixIcon: CupertinoIcons.person_3_fill,
                    ),
                    const SizedBox(height: 20),
                    IosGlassBlueButton(
                      blueColor: Color(tracker.colorValue),
                      isDark: isDark,
                      onTap: () {
                        final text = bulkNamesCtrl.text.trim();
                        if (text.isEmpty) return;

                        final lines = text
                            .split(RegExp(r'[\r\n,]+'))
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList();

                        if (lines.isEmpty) return;

                        final newItems = lines.map((name) {
                          return TrackItem(
                            id: const Uuid().v4(),
                            name: name,
                            status: tracker.defaultStatus,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          );
                        }).toList();

                        ref
                            .read(trackListProvider.notifier)
                            .addMultipleItems(tracker.id, newItems);

                        HapticFeedback.mediumImpact();
                        Navigator.pop(ctx);
                        GlassToast.show(context,
                            message: 'Added ${newItems.length} entries');
                      },
                      child: const Center(
                        child: Text(
                          'Add All to List',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Mode 2: One by One
                    GlassTextField(
                      label: 'Name or Item',
                      hint: 'Enter item or name...',
                      controller: singleNameCtrl,
                      prefixIcon: CupertinoIcons.person,
                    ),
                    const SizedBox(height: 12),
                    GlassTextField(
                      label: 'Note (Optional)',
                      hint: 'Add an optional note...',
                      controller: singleNoteCtrl,
                      prefixIcon: CupertinoIcons.doc_text,
                    ),
                    const SizedBox(height: 20),
                    IosGlassBlueButton(
                      blueColor: Color(tracker.colorValue),
                      isDark: isDark,
                      onTap: () {
                        final name = singleNameCtrl.text.trim();
                        if (name.isEmpty) return;

                        final newItem = TrackItem(
                          id: const Uuid().v4(),
                          name: name,
                          status: tracker.defaultStatus,
                          note: singleNoteCtrl.text.trim().isEmpty
                              ? null
                              : singleNoteCtrl.text.trim(),
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );

                        ref
                            .read(trackListProvider.notifier)
                            .addItem(tracker.id, newItem);

                        HapticFeedback.lightImpact();
                        Navigator.pop(ctx);
                        GlassToast.show(context, message: '$name added');
                      },
                      child: const Center(
                        child: Text(
                          'Add to List',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditItemModal(TrackList tracker, TrackItem item, bool isDark) {
    final nameCtrl = TextEditingController(text: item.name);
    final noteCtrl = TextEditingController(text: item.note ?? '');
    String selectedStatus = item.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Edit Entry',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1A0A2E),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Icon(
                          CupertinoIcons.clear_circled_solid,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GlassTextField(
                    label: 'Name or Item',
                    controller: nameCtrl,
                    prefixIcon: CupertinoIcons.person,
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    label: 'Note (Optional)',
                    controller: noteCtrl,
                    prefixIcon: CupertinoIcons.doc_text,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Status:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: tracker.statusOptions.map((st) {
                      final isSel = selectedStatus == st;
                      final isComp = st == tracker.completedStatus;
                      final color = isComp
                          ? const Color(0xFF34C759)
                          : const Color(0xFFFF9500);

                      return GestureDetector(
                        onTap: () => setModalState(() => selectedStatus = st),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? color.withValues(alpha: isDark ? 0.3 : 0.18)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.04)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? color : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            st,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  isSel ? FontWeight.w700 : FontWeight.w500,
                              color: isSel
                                  ? color
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      // Delete item button
                      CircularGlassButton(
                        size: 48,
                        icon: CupertinoIcons.trash,
                        iconColor: Colors.red,
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          final originalIndex = tracker.items.indexWhere((it) => it.id == item.id);
                          final deletedItem = item;
                          Navigator.pop(ctx);
                          ref
                              .read(trackListProvider.notifier)
                              .deleteItem(tracker.id, item.id);
                          GlassToast.show(
                            context,
                            message: '${deletedItem.name} deleted',
                            actionLabel: 'Undo',
                            duration: const Duration(seconds: 3),
                            onAction: () {
                              HapticFeedback.mediumImpact();
                              ref.read(trackListProvider.notifier).insertItemAt(
                                    tracker.id,
                                    originalIndex >= 0 ? originalIndex : 0,
                                    deletedItem,
                                  );
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: IosGlassBlueButton(
                          blueColor: Color(tracker.colorValue),
                          isDark: isDark,
                          onTap: () {
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty) return;

                            final updated = item.copyWith(
                              name: name,
                              status: selectedStatus,
                              note: noteCtrl.text.trim().isEmpty
                                  ? null
                                  : noteCtrl.text.trim(),
                              updatedAt: DateTime.now(),
                            );

                            ref
                                .read(trackListProvider.notifier)
                                .updateItem(tracker.id, updated);
                            Navigator.pop(ctx);
                            GlassToast.show(context,
                                message: 'Entry updated');
                          },
                          child: const Center(
                            child: Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final trackLists = ref.watch(trackListProvider);
    final tracker = trackLists.where((t) => t.id == widget.trackerId).firstOrNull;

    if (tracker == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: GlassBackground(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tracker not found'),
                const SizedBox(height: 12),
                CircularGlassButton(
                  size: 44,
                  icon: CupertinoIcons.back,
                  isDark: isDark,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final accentColor = Color(tracker.colorValue);

    // Apply filters & search
    List<TrackItem> items = tracker.items.where((it) {
      // Filter status
      if (_filter == TrackListFilter.completed) {
        if (it.status != tracker.completedStatus) return false;
      } else if (_filter == TrackListFilter.pending) {
        if (it.status == tracker.completedStatus) return false;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = it.name.toLowerCase().contains(q);
        final matchNote = it.note?.toLowerCase().contains(q) ?? false;
        if (!matchName && !matchNote) return false;
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        ambientColor: accentColor,
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // ─── Top App Bar ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Row(
                      children: [
                        CircularGlassButton(
                          size: 44,
                          icon: CupertinoIcons.back,
                          isDark: isDark,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tracker.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A0A2E),
                                ),
                              ),
                              if (tracker.description != null &&
                                  tracker.description!.isNotEmpty)
                                Text(
                                  tracker.description!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Add Multiple Entries Shortcut
                        CircularGlassButton(
                          size: 44,
                          icon: CupertinoIcons.person_3_fill,
                          iconSize: 18,
                          isDark: isDark,
                          onTap: () => _showAddEntryModal(tracker, isDark, initialAllInOne: true),
                        ),
                        const SizedBox(width: 10),
                        // Settings / Edit tracker
                        CircularGlassButton(
                          size: 44,
                          icon: CupertinoIcons.slider_horizontal_3,
                          iconSize: 18,
                          isDark: isDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => CreateEditTrackListScreen(
                                  initialTrackList: tracker,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // ─── Statistics Header Card ───────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: _buildStatisticsCard(tracker, isDark, accentColor),
                  ),

                  // ─── Search and Filters Row ───────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.white.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF38383A)
                                    : const Color(0xFFE5E5EA),
                                width: 0.8,
                              ),
                            ),
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: (val) =>
                                  setState(() => _searchQuery = val.trim()),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search items or people...',
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                                prefixIcon: Icon(
                                  CupertinoIcons.search,
                                  size: 16,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          _searchCtrl.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                        child: Icon(
                                          CupertinoIcons.clear_circled_solid,
                                          size: 16,
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black45,
                                        ),
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter Segmented Pills
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      children: [
                        _buildFilterPill(
                          label: 'All (${tracker.totalCount})',
                          filter: TrackListFilter.all,
                          isDark: isDark,
                          accentColor: accentColor,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          label:
                              '${tracker.completedStatus} (${tracker.completedCount})',
                          filter: TrackListFilter.completed,
                          isDark: isDark,
                          accentColor: const Color(0xFF34C759),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          label:
                              '${tracker.defaultStatus} (${tracker.pendingCount})',
                          filter: TrackListFilter.pending,
                          isDark: isDark,
                          accentColor: const Color(0xFFFF3B30),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ─── Items List ───────────────────────────────────────────
                  Expanded(
                    child: items.isEmpty
                        ? _buildEmptyItemsState(isDark)
                        : _buildItemsList(tracker, items, isDark, accentColor),
                  ),
                ],
              ),
            ),

            // ─── Add Item Liquid Glass Button ──────────────────────────────
            Positioned(
              right: 22,
              bottom: (MediaQuery.of(context).padding.bottom > 0
                      ? MediaQuery.of(context).padding.bottom
                      : 14) +
                  16,
              child: FluentLiquidGlassButton(
                size: 60,
                isDark: isDark,
                iconColor: GlassTheme.accentPrimary,
                onTap: () => _showAddEntryModal(tracker, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(
      TrackList tracker, bool isDark, Color accentColor) {
    final progress = tracker.progressPercentage;

    return GlassContainer(
      borderRadius: GlassTheme.radiusLarge,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      fillOpacity: isDark ? 0.2 : 0.45,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('TOTAL', '${tracker.totalCount}', isDark,
                  isDark ? Colors.white : Colors.black87),
              _buildStatDivider(isDark),
              _buildStatItem(tracker.completedStatus.toUpperCase(),
                  '${tracker.completedCount}', isDark, const Color(0xFF34C759)),
              _buildStatDivider(isDark),
              _buildStatItem(tracker.defaultStatus.toUpperCase(),
                  '${tracker.pendingCount}', isDark, const Color(0xFFFF3B30)),
              _buildStatDivider(isDark),
              _buildStatItem('PROGRESS', '${progress.toStringAsFixed(1)}%',
                  isDark, accentColor),
            ],
          ),
          const SizedBox(height: 14),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (progress / 100).clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF81C784), // Light fresh green (starting)
                        Color(0xFF34C759), // Authentic Apple System Green (finishing)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF34C759).withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, bool isDark, Color valColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: valColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 26,
      color: isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.black.withValues(alpha: 0.08),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required TrackListFilter filter,
    required bool isDark,
    required Color accentColor,
  }) {
    final isSelected = _filter == filter;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _filter = filter);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: isDark ? 0.3 : 0.15)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA)),
            width: isSelected ? 1.3 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : accentColor)
                : (isDark ? Colors.white60 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyItemsState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.square_list,
              size: 48,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No matching entries'
                  : 'No entries added yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term or clear the filter.'
                  : 'Tap the + button to add an entry or use the 👥 icon above to paste multiple names at once.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(
    TrackList tracker,
    List<TrackItem> items,
    bool isDark,
    Color accentColor,
  ) {
    // If we're showing "All" and no search query is active, support ReorderableListView
    final canReorder = _filter == TrackListFilter.all && _searchQuery.isEmpty;

    if (canReorder) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        onReorder: (oldIdx, newIdx) {
          ref
              .read(trackListProvider.notifier)
              .reorderItems(tracker.id, oldIdx, newIdx);
        },
        itemBuilder: (ctx, idx) {
          final item = items[idx];
          return Container(
            key: ValueKey(item.id),
            margin: const EdgeInsets.only(bottom: 10),
            child: _buildItemRow(tracker, item, isDark, accentColor),
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) {
        final item = items[idx];
        return _buildItemRow(tracker, item, isDark, accentColor);
      },
    );
  }

  Widget _buildItemRow(
    TrackList tracker,
    TrackItem item,
    bool isDark,
    Color accentColor,
  ) {
    final isCompleted = item.status == tracker.completedStatus;
    final statusColor =
        isCompleted ? const Color(0xFF34C759) : const Color(0xFFFF3B30);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (dir) async {
        HapticFeedback.lightImpact();
        final originalIndex =
            tracker.items.indexWhere((it) => it.id == item.id);
        final deletedItem = item;

        ref.read(trackListProvider.notifier).deleteItem(tracker.id, item.id);

        GlassToast.show(
          context,
          message: '${item.name} deleted',
          actionLabel: 'Undo',
          duration: const Duration(seconds: 3),
          onAction: () {
            HapticFeedback.mediumImpact();
            ref.read(trackListProvider.notifier).insertItemAt(
                  tracker.id,
                  originalIndex >= 0 ? originalIndex : 0,
                  deletedItem,
                );
          },
        );
        return true;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(GlassTheme.radiusMedium),
        ),
        child: const Icon(CupertinoIcons.trash, color: Colors.white, size: 22),
      ),
      child: GlassContainer(
        borderRadius: GlassTheme.radiusMedium,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        fillOpacity: isDark ? 0.16 : 0.38,
        // edit moved to 6-dot handle
        child: Row(
          children: [
            // Status Checkbox / Toggle
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                ref
                    .read(trackListProvider.notifier)
                    .toggleItemStatus(tracker.id, item.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? statusColor
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.04)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCompleted
                        ? statusColor
                        : (isDark
                            ? const Color(0xFF55555A)
                            : const Color(0xFFC7C7CC)),
                    width: 1.6,
                  ),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 14),

            // Item Name + Note
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isCompleted ? FontWeight.w500 : FontWeight.w600,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted
                          ? (isDark ? Colors.white54 : Colors.black45)
                          : (isDark ? Colors.white : const Color(0xFF1A0A2E)),
                    ),
                  ),
                  if (item.note != null && item.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.note!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Authentic iOS White Rounded-Edge Rectangle Status Badge
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.lightImpact();
                ref
                    .read(trackListProvider.notifier)
                    .toggleItemStatus(tracker.id, item.id);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFFFFFFFF).withValues(alpha: 0.94)
                      : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0x33FFFFFF)
                        : const Color(0x18000000),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                    color: isCompleted
                        ? const Color(0xFF34C759)
                        : const Color(0xFFFF3B30),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.lightImpact();
                _showEditItemModal(tracker, item, isDark);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Icon(
                  Icons.drag_indicator_rounded,
                  size: 20,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

