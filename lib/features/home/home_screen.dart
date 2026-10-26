import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/widgets/glass_background.dart';
import '../../core/widgets/glass_container.dart';
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
          ],
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: _navIndex == 0 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: _navIndex == 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 180),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: (MediaQuery.of(context).padding.bottom > 0
                      ? MediaQuery.of(context).padding.bottom
                      : 14) +
                  62 +
                  16,
              right: 6,
            ),
            child: _GlassFab(
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (_) => const CreateTaskScreen()),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                // Theme toggle
                _TopBarButton(
                  icon: widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  onTap: widget.onThemeToggle,
                  isDark: widget.isDark,
                ),
                const SizedBox(width: 10),
                // Focus Mode / Squircle Control Center Launcher
                _TopBarButton(
                  icon: focusState.isRunning
                      ? CupertinoIcons.flame_fill
                      : CupertinoIcons.timer,
                  onTap: widget.onFocusTap,
                  isDark: widget.isDark,
                  customColor: focusState.isRunning ? const Color(0xFF0A84FF) : null,
                  badgeText: focusState.isRunning
                      ? '${focusState.remainingSeconds ~/ 60}m'
                      : null,
                ),
                const SizedBox(width: 10),
                // + Create Task
                _TopBarButton(
                  icon: CupertinoIcons.plus,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (_) => const CreateTaskScreen()),
                    );
                  },
                  isDark: widget.isDark,
                  isAccent: true,
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

// ─── Helpers ───────────────────────────────────────────────────────────────────

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final bool isAccent;
  final Color? customColor;
  final String? badgeText;

  const _TopBarButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.isAccent = false,
    this.customColor,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        borderRadius: GlassTheme.radiusMedium,
        fillOpacity: isAccent
            ? (isDark ? 0.24 : 0.28)
            : (customColor != null ? 0.22 : (isDark ? 0.08 : 0.14)),
        tintColor: isAccent
            ? GlassTheme.accentPrimary
            : customColor,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: customColor ??
                  (isAccent
                      ? (isDark ? const Color(0xFF64B5F6) : GlassTheme.accentPrimary)
                      : (isDark ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF1A0A2E))),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 4),
              Text(
                badgeText!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: customColor ?? (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GlassFab extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _GlassFab({required this.isDark, required this.onTap});

  @override
  State<_GlassFab> createState() => _GlassFabState();
}

class _GlassFabState extends State<_GlassFab> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: GlassTheme.accentPrimary.withValues(alpha: isDark ? 0.40 : 0.32),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.40)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Translucent Liquid Glass Body with Accent Gradient
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                GlassTheme.accentPrimary.withValues(alpha: 0.70),
                                GlassTheme.accentSecondary.withValues(alpha: 0.45),
                                Colors.black.withValues(alpha: 0.35),
                              ]
                            : [
                                GlassTheme.accentPrimary.withValues(alpha: 0.85),
                                GlassTheme.accentSecondary.withValues(alpha: 0.70),
                                Colors.white.withValues(alpha: 0.40),
                              ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),

                  // 2. Pure Monochromatic Specular Top Sheen
                  Positioned(
                    top: 2,
                    left: 10,
                    right: 10,
                    height: 2.5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: isDark ? 0.85 : 0.95),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 3. Pure Monochromatic Specular Bottom Floor Reflection
                  Positioned(
                    bottom: 2,
                    left: 12,
                    right: 12,
                    height: 1.8,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: isDark ? 0.35 : 0.50),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 4. Perimeter Glass Border
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: isDark ? 0.35 : 0.65),
                        width: 1.0,
                      ),
                    ),
                  ),

                  // 5. Centered Plus Icon
                  const Center(
                    child: Icon(
                      CupertinoIcons.plus,
                      color: Colors.white,
                      size: 28,
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
