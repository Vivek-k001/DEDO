import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/widgets/glass_background.dart';
import '../../providers/theme_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/focus_provider.dart';
import '../focus/focus_mode_modal.dart';
import '../task/create_task_screen.dart';
import '../category/category_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/date_strip.dart';
import 'widgets/category_chips.dart';
import 'widgets/task_card.dart';
import '../../core/widgets/bottom_nav_bar.dart';

import '../../services/hive_service.dart';
import '../profile/widgets/birthday_picker_modal.dart';
import 'widgets/stacked_sticky_icon.dart';
import '../notes/sticky_grid_overlay.dart';
import '../../core/widgets/circular_glass_button.dart';
import '../../core/widgets/fluent_liquid_glass_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _navIndex = 0;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  late final TabController _tabCtrl;
  final GlobalKey<DateStripState> _dateStripKey = GlobalKey<DateStripState>();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBirthdayCelebration();
    });
  }

  void _resetToToday() {
    HapticFeedback.selectionClick();
    setState(() => _selectedDate = DateTime.now());
    _dateStripKey.currentState?.scrollToToday();
  }

  void _checkBirthdayCelebration() {
    final profile = ref.read(profileProvider);
    if (profile?.birthday == null) return;

    final now = DateTime.now();
    final bday = profile!.birthday!;
    final isBirthdayToday = (now.month == bday.month && now.day == bday.day);

    if (isBirthdayToday) {
      final lastYearCelebrated =
          HiveService.settings.get('lastBirthdayYearCelebrated', defaultValue: 0);
      if (lastYearCelebrated != now.year) {
        HiveService.settings.put('lastBirthdayYearCelebrated', now.year);
        BirthdayCelebrationModal.show(
          context,
          userName: profile.username,
          birthday: profile.birthday,
        );
      }
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final categories = ref.watch(categoryProvider);

    Color? ambientColor;
    if (_selectedCategory != null) {
      final selectedCat = categories.cast().where((c) => c.id == _selectedCategory).firstOrNull;
      if (selectedCat != null) ambientColor = Color(selectedCat.colorValue);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: GlassBackground(
        ambientColor: ambientColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            IndexedStack(
              index: _navIndex,
              children: [
                _HomeBody(
                  selectedDate: _selectedDate,
                  selectedCategory: _selectedCategory,
                  tabCtrl: _tabCtrl,
                  isDark: isDark,
                  onDateSelected: (d) => setState(() => _selectedDate = d),
                  onCategorySelected: (c) => setState(() => _selectedCategory = c),
                  onFocusTap: () => FocusControlCenterModal.show(context),
                  onThemeToggle: () => ref.read(themeProvider.notifier).toggle(),
                  onOpenCategory: () => setState(() => _navIndex = 1),
                  onAddTask: (task) {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => CreateTaskScreen(initialTask: task)),
                    );
                  },
                  dateStripKey: _dateStripKey,
                  onResetToToday: _resetToToday,
                ),
                const CategoryScreen(isRootTab: true),
                const ProfileScreen(),
              ],
            ),

            // ─── Linear Backdrop Blur Under & Below Floating Navbar ───
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 120,
              child: IgnorePointer(
                child: ClipRect(
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black87,
                          Colors.black,
                        ],
                        stops: [0.0, 0.45, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              (isDark ? Colors.black : Colors.white)
                                  .withValues(alpha: isDark ? 0.35 : 0.45),
                              (isDark ? Colors.black : Colors.white)
                                  .withValues(alpha: isDark ? 0.70 : 0.80),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ─── Static Liquid Glass + (Create Task) Button ───
            Positioned(
              right: 20,
              bottom: (MediaQuery.of(context).padding.bottom > 0
                      ? MediaQuery.of(context).padding.bottom
                      : 14) +
                  68 +
                  14,
              child: AnimatedScale(
                scale: _navIndex == 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: _navIndex == 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 160),
                  child: IgnorePointer(
                    ignoring: _navIndex != 0,
                    child: FluentLiquidGlassButton(
                      size: 62,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => const CreateTaskScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: LiquidGlassNavBar(
        isDark: isDark,
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == 0 && _navIndex == 0) {
            _resetToToday();
          } else if (i == 0) {
            _resetToToday();
          }
          setState(() => _navIndex = i);
        },
        items: const [
          LiquidNavItem(
            icon: CupertinoIcons.home,
            label: 'Home',
          ),
          LiquidNavItem(
            icon: CupertinoIcons.square_grid_2x2,
            label: 'Categories',
          ),
          LiquidNavItem(
            icon: CupertinoIcons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─── Home Body ─────────────────────────────────────────────────────────────────

class _HomeBody extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final String? selectedCategory;
  final TabController tabCtrl;
  final bool isDark;
  final void Function(DateTime) onDateSelected;
  final void Function(String?) onCategorySelected;
  final VoidCallback onFocusTap;
  final VoidCallback onThemeToggle;
  final VoidCallback onOpenCategory;
  final void Function(dynamic task) onAddTask;
  final GlobalKey<DateStripState>? dateStripKey;
  final VoidCallback onResetToToday;

  const _HomeBody({
    required this.selectedDate,
    required this.selectedCategory,
    required this.tabCtrl,
    required this.isDark,
    required this.onDateSelected,
    required this.onCategorySelected,
    required this.onFocusTap,
    required this.onThemeToggle,
    required this.onOpenCategory,
    required this.onAddTask,
    this.dateStripKey,
    required this.onResetToToday,
  });

  @override
  ConsumerState<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends ConsumerState<_HomeBody> {
  String _greeting(String? name) {
    final hour = DateTime.now().hour;
    final userName = name ?? 'there';
    if (hour < 12) {
      return 'Good morning, $userName ☀️';
    } else if (hour < 17) {
      return 'Good afternoon, $userName 🌤️';
    } else {
      return 'Good evening, $userName 🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final categories = ref.watch(categoryProvider);
    final profile = ref.watch(profileProvider);
    final focusState = ref.watch(focusProvider);

    // Compute task counts per date ('yyyy-MM-dd')
    final taskCountMap = <String, int>{};
    for (final t in tasks) {
      final key =
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}';
      taskCountMap[key] = (taskCountMap[key] ?? 0) + 1;
    }

    List tasksFiltered = tasks.where((t) {
      final dateMatch = t.date.year == widget.selectedDate.year &&
          t.date.month == widget.selectedDate.month &&
          t.date.day == widget.selectedDate.day;
      final catMatch = widget.selectedCategory == null ||
          t.categoryId == widget.selectedCategory;
      return dateMatch && catMatch;
    }).toList();

    final pending = tasksFiltered.where((t) => !t.isCompleted).toList();
    final completed = tasksFiltered.where((t) => t.isCompleted).toList();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // ─── Top Bar ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onResetToToday,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'DEDO',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: widget.isDark
                                    ? Colors.white
                                    : const Color(0xFF1A0A2E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            StackedStickyIcon(
                              isDark: widget.isDark,
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                StickyGridOverlay.show(
                                  context,
                                  isDark: widget.isDark,
                                );
                              },
                            ),
                          ],
                        ),
                        Text(
                          _greeting(profile?.username),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: widget.isDark
                                ? Colors.white.withValues(alpha: 0.65)
                                : Colors.black.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Focus Mode Launcher
                CircularGlassButton(
                  size: 44,
                  icon: focusState.isRunning
                      ? CupertinoIcons.flame_fill
                      : CupertinoIcons.timer,
                  iconColor: focusState.isRunning ? const Color(0xFF0A84FF) : null,
                  badgeText: focusState.isRunning
                      ? '${focusState.remainingSeconds ~/ 60}m'
                      : null,
                  isDark: widget.isDark,
                  onTap: widget.onFocusTap,
                ),
                const SizedBox(width: 12),
                // Theme toggle
                CircularGlassButton(
                  size: 44,
                  icon: widget.isDark
                      ? CupertinoIcons.sun_max_fill
                      : CupertinoIcons.moon_fill,
                  isDark: widget.isDark,
                  onTap: widget.onThemeToggle,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Date Strip ──────────────────────────────────────────────────
          DateStrip(
            key: widget.dateStripKey,
            selectedDate: widget.selectedDate,
            onDateSelected: widget.onDateSelected,
            taskCountMap: taskCountMap,
          ),

          const SizedBox(height: 16),

          // ─── Category Chips ───────────────────────────────────────────────
          CategoryChips(
            selected: widget.selectedCategory,
            onSelected: widget.onCategorySelected,
            categories: categories,
          ),

          const SizedBox(height: 16),

          // ─── Liquid Glass Segmented Control ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? const Color(0xFF1C1C1E)
                    : const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: widget.tabCtrl,
                onTap: (_) => HapticFeedback.selectionClick(),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF2C2C2E) : Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 4,
                      offset: Offset(0, 1.5),
                    ),
                  ],
                ),
                dividerColor: Colors.transparent,
                labelColor: widget.isDark ? Colors.white : Colors.black,
                unselectedLabelColor: const Color(0xFF8E8E93),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  letterSpacing: -0.2,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13.5,
                  letterSpacing: -0.2,
                ),
                tabs: [
                  Tab(text: 'Pending (${pending.length})'),
                  Tab(text: 'Done (${completed.length})'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ─── Task Lists ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: widget.tabCtrl,
              children: [
                _TaskList(tasks: pending, onTap: (task) {
                  widget.onAddTask(task);
                }),
                _TaskList(tasks: completed, onTap: (task) {
                  widget.onAddTask(task);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List tasks;
  final void Function(dynamic) onTap;

  const _TaskList({required this.tasks, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 56,
              color: GlassTheme.accentPrimary.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 12),
            Text(
              'No tasks here',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: tasks.length,
      itemBuilder: (_, i) => TaskCard(
        task: tasks[i],
        onTap: () => onTap(tasks[i]),
      ),
    );
  }
}
