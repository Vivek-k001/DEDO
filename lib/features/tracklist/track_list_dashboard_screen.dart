import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../core/widgets/glass_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/circular_glass_button.dart';
import '../../../core/widgets/fluent_liquid_glass_button.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../../models/track_list.dart';
import '../../../providers/track_list_provider.dart';
import '../../../providers/theme_provider.dart';
import 'create_track_list_screen.dart';
import 'track_list_detail_screen.dart';

class TrackListDashboardScreen extends ConsumerStatefulWidget {
  const TrackListDashboardScreen({super.key});

  @override
  ConsumerState<TrackListDashboardScreen> createState() =>
      _TrackListDashboardScreenState();
}

class _TrackListDashboardScreenState
    extends ConsumerState<TrackListDashboardScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, TrackList tracker) {
    HapticFeedback.mediumImpact();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Tracker?'),
        content: Text(
          'Are you sure you want to delete "${tracker.title}" and all its ${tracker.items.length} items? This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(trackListProvider.notifier).deleteTrackList(tracker.id);
              GlassToast.show(context, message: 'Tracker deleted');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final trackLists = ref.watch(trackListProvider);

    final filtered = trackLists.where((t) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final matchTitle = t.title.toLowerCase().contains(q);
      final matchDesc = t.description?.toLowerCase().contains(q) ?? false;
      return matchTitle || matchDesc;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // ─── Header ───────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
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
                                'TrackList',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A0A2E),
                                ),
                              ),
                              Text(
                                '${trackLists.length} ${trackLists.length == 1 ? 'tracker' : 'trackers'} active',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.6)
                                      : Colors.black.withValues(alpha: 0.55),
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),

                  // ─── Search Bar ───────────────────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(16),
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
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search trackers...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                            size: 18,
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
                                    size: 18,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black45,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),

                  // ─── Trackers List ────────────────────────────────────────
                  Expanded(
                    child: filtered.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                            physics: const BouncingScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (ctx, idx) {
                              final tracker = filtered[idx];
                              return _buildTrackerCard(tracker, isDark);
                            },
                          ),
                  ),
                ],
              ),
            ),

            // ─── Floating Create Tracker Liquid Glass Button ──────────
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
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => const CreateEditTrackListScreen(),
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: GlassTheme.accentPrimary
                    .withValues(alpha: isDark ? 0.16 : 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.square_list,
                size: 40,
                color: GlassTheme.accentPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No trackers found'
                  : 'No TrackLists Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A0A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try searching with different keywords.'
                  : 'Track attendance, payments, class contributions, RSVPs, distribution & more with real-time stats.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackerCard(TrackList tracker, bool isDark) {
    final progress = tracker.progressPercentage;
    final color = Color(tracker.colorValue);

    return Dismissible(
      key: ValueKey(tracker.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (dir) async {
        _confirmDelete(context, tracker);
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(GlassTheme.radiusLarge),
        ),
        child: const Icon(CupertinoIcons.trash, color: Colors.white, size: 26),
      ),
      child: GlassContainer(
        borderRadius: GlassTheme.radiusLarge,
        padding: const EdgeInsets.all(18),
        fillOpacity: isDark ? 0.16 : 0.35,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => TrackListDetailScreen(trackerId: tracker.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Status pills + Context menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color Accent indicator bar
                Container(
                  width: 4,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tracker.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1A0A2E),
                        ),
                      ),
                      if (tracker.description != null &&
                          tracker.description!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          tracker.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Popup menu
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: isDark ? Colors.white60 : Colors.black54,
                    size: 20,
                  ),
                  color: isDark ? const Color(0xFF1E1E22) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (val) {
                    if (val == 'edit') {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) =>
                              CreateEditTrackListScreen(initialTrackList: tracker),
                        ),
                      );
                    } else if (val == 'delete') {
                      _confirmDelete(context, tracker);
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.pencil,
                              size: 16,
                              color: isDark ? Colors.white70 : Colors.black87),
                          const SizedBox(width: 10),
                          const Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.trash,
                              size: 16, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress Bar
            Stack(
              children: [
                Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (progress / 100).clamp(0.0, 1.0),
                  child: Container(
                    height: 7,
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
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Metrics row: Total | Completed | Pending | Updated
            Row(
              children: [
                _buildMetricChip(
                  label: 'Total',
                  value: '${tracker.totalCount}',
                  isDark: isDark,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                const SizedBox(width: 8),
                _buildMetricChip(
                  label: tracker.completedStatus,
                  value: '${tracker.completedCount}',
                  isDark: isDark,
                  color: const Color(0xFF34C759),
                ),
                const SizedBox(width: 8),
                _buildMetricChip(
                  label: tracker.defaultStatus,
                  value: '${tracker.pendingCount}',
                  isDark: isDark,
                  color: const Color(0xFFFF3B30),
                ),
                const Spacer(),
                Text(
                  '${progress.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              'Updated ${DateFormat('MMM d, h:mm a').format(tracker.updatedAt)}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip({
    required String label,
    required String value,
    required bool isDark,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

