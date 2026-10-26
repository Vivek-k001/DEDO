import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/widgets/glass_background.dart';
import '../../models/user_profile.dart';
import '../../providers/profile_provider.dart';
import '../home/home_screen.dart';

enum _OnboardingStage {
  hello,
  input,
  birthday,
  welcome,
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  _OnboardingStage _stage = _OnboardingStage.hello;
  final _nameCtrl = TextEditingController();
  final _focusNode = FocusNode();
  String _savedName = '';
  DateTime? _selectedBirthday;
  bool _isLoading = false;

  // Animation controllers
  late final AnimationController _helloAnimCtrl;
  late final Animation<double> _helloFade;
  late final Animation<double> _helloScale;

  late final AnimationController _inputAnimCtrl;
  late final Animation<double> _inputFade;
  late final Animation<Offset> _inputSlide;

  late final AnimationController _welcomeAnimCtrl;
  late final Animation<double> _welcomeFade;
  late final Animation<double> _welcomeScale;

  Timer? _helloTimer;

  @override
  void initState() {
    super.initState();

    // 1. Hello stage animations: graceful visible fade in & gentle breathing scale
    _helloAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _helloFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _helloAnimCtrl,
        curve: const Interval(0.05, 0.90, curve: Curves.easeOutCubic),
      ),
    );
    _helloScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _helloAnimCtrl,
        curve: Curves.easeOutCubic,
      ),
    );

    // 2. Input stage animations
    _inputAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _inputFade = CurvedAnimation(
      parent: _inputAnimCtrl,
      curve: Curves.easeOutCubic,
    );
    _inputSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _inputAnimCtrl,
      curve: Curves.easeOutCubic,
    ));

    // 3. Welcome stage animations with sequential staging:
    // First: Welcome SVG fades and scales in gracefully (0.0 -> 0.50)
    // Then: User's name smoothly fades in and rises (0.45 -> 1.0)
    _welcomeAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _welcomeFade = CurvedAnimation(
      parent: _welcomeAnimCtrl,
      curve: const Interval(0.0, 0.52, curve: Curves.easeOutCubic),
    );
    _welcomeScale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _welcomeAnimCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    // Start Stage 1 (hello) on first frame so fade in is completely visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _helloAnimCtrl.forward();
      }
    });
    _helloTimer = Timer(const Duration(milliseconds: 2900), () {
      if (mounted) {
        _transitionToInput();
      }
    });
  }

  void _transitionToInput() {
    setState(() => _stage = _OnboardingStage.input);
    _inputAnimCtrl.forward();
  }

  void _transitionToBirthday() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _savedName = name;
      _stage = _OnboardingStage.birthday;
    });
  }

  Future<void> _finishOnboarding() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    // Save profile with username and birthday to Hive
    await ref.read(profileProvider.notifier).saveProfile(UserProfile(
          username: _savedName,
          joinedAt: DateTime.now(),
          birthday: _selectedBirthday,
        ));

    if (!mounted) return;

    // Transition to Stage 4 (Welcome, then $name)
    setState(() {
      _isLoading = false;
      _stage = _OnboardingStage.welcome;
    });
    _welcomeAnimCtrl.forward();

    // Pause to appreciate the crisp Welcome vector, followed by name reveal, then slow transition to home
    await Future.delayed(const Duration(milliseconds: 3200));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1200),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: anim,
                curve: Curves.easeInOutCubic,
              ),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _helloTimer?.cancel();
    _helloAnimCtrl.dispose();
    _inputAnimCtrl.dispose();
    _welcomeAnimCtrl.dispose();
    _nameCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 750),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildCurrentStage(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStage(bool isDark) {
    switch (_stage) {
      case _OnboardingStage.hello:
        return _buildHelloStage(isDark);
      case _OnboardingStage.input:
        return _buildInputStage(isDark);
      case _OnboardingStage.birthday:
        return _buildBirthdayStage(isDark);
      case _OnboardingStage.welcome:
        return _buildWelcomeStage(isDark);
    }
  }

  // ─── Stage 1: Apple iOS Cursive Hello ──────────────────────────────────────
  Widget _buildHelloStage(bool isDark) {
    final helloAsset = isDark
        ? 'assets/images/hello_white.png'
        : 'assets/images/hello_dark.png';

    return Center(
      key: const ValueKey('hello_stage'),
      child: FadeTransition(
        opacity: _helloFade,
        child: ScaleTransition(
          scale: _helloScale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Liquid glow backdrop
              Container(
                width: 300,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: isDark ? 0.08 : 0.05),
                      blurRadius: 80,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    helloAsset,
                    width: 260,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Stage 2: Name Input Step with Minimal Dedo Header ──────────────────────
  Widget _buildInputStage(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A0A2E);
    final subtextColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.5);

    return FadeTransition(
      key: const ValueKey('input_stage'),
      opacity: _inputFade,
      child: SlideTransition(
        position: _inputSlide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Minimal Apple SF Dedo Brand Header (Top-Left)
              Text(
                'Dedo',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const Spacer(flex: 2),

              // Clean Human Typography
              Text(
                'Welcome to Dedo',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What should we call you?',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.2,
                  color: subtextColor,
                ),
              ),

              const SizedBox(height: 32),

              // Liquid Glass Name Input Container
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0x1AFFFFFF)
                          : const Color(0x1A000000),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.16)
                            : Colors.black.withValues(alpha: 0.09),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : const Color(0xFF9E8DB5))
                              .withValues(alpha: isDark ? 0.35 : 0.10),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _nameCtrl,
                      focusNode: _focusNode,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                      cursorColor: const Color(0xFF007AFF),
                      cursorWidth: 2.0,
                      cursorRadius: const Radius.circular(2),
                      textCapitalization: TextCapitalization.words,
                      onSubmitted: (_) => _transitionToBirthday(),
                      decoration: InputDecoration(
                        hintText: 'Enter your name...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: subtextColor.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Icon(
                            CupertinoIcons.person_crop_circle,
                            color: Color(0xFF007AFF),
                            size: 24,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Vibrant iOS Blue Continue Button
              GestureDetector(
                onTap: _transitionToBirthday,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.38),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Continue',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          CupertinoIcons.arrow_right,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Stage 3: iOS Birthday Picker ──────────────────────────────────────────
  Widget _buildBirthdayStage(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A0A2E);
    final subtextColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF636366);

    final dateFormatted = _selectedBirthday == null
        ? 'Select your date of birth'
        : '${_selectedBirthday!.day.toString().padLeft(2, '0')} / ${_selectedBirthday!.month.toString().padLeft(2, '0')} / ${_selectedBirthday!.year}';

    return Center(
      key: const ValueKey('birthday_stage'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Subtle elegant calendar icon
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF007AFF).withValues(alpha: 0.12),
                border: Border.all(
                  color: const Color(0xFF007AFF).withValues(alpha: 0.30),
                  width: 1.0,
                ),
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.calendar,
                  color: Color(0xFF007AFF),
                  size: 30,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Date of birth',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.7,
                color: textColor,
              ),
            ),

            const SizedBox(height: 32),

            // Date Selection Pill / Modal trigger
            GestureDetector(
              onTap: () => _showCupertinoDatePicker(isDark),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0x1AFFFFFF)
                          : const Color(0x1A000000),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.16)
                            : Colors.black.withValues(alpha: 0.09),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.calendar_today,
                          color: Color(0xFF007AFF),
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            dateFormatted,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: _selectedBirthday == null
                                  ? FontWeight.w400
                                  : FontWeight.w700,
                              color: _selectedBirthday == null
                                  ? subtextColor
                                  : textColor,
                            ),
                          ),
                        ),
                        Icon(
                          CupertinoIcons.chevron_down,
                          size: 16,
                          color: subtextColor.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Continue Button
            GestureDetector(
              onTap: _isLoading ? null : _finishOnboarding,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007AFF).withValues(alpha: 0.38),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoading
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Get Started',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              CupertinoIcons.checkmark_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Skip for now button
            CupertinoButton(
              onPressed: _isLoading ? null : _finishOnboarding,
              child: Text(
                'Skip for now',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: subtextColor,
                ),
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  void _showCupertinoDatePicker(bool isDark) {
    HapticFeedback.lightImpact();
    DateTime tempDate = _selectedBirthday ?? DateTime(2000, 1, 1);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: 310,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1C1C1E).withValues(alpha: 0.95)
                    : const Color(0xFFF2F2F7).withValues(alpha: 0.95),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: Column(
                children: [
                  // iOS Toolbar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(modalCtx),
                          child: const Text('Cancel'),
                        ),
                        Text(
                          'Date of Birth',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedBirthday = tempDate);
                            Navigator.pop(modalCtx);
                          },
                          child: const Text(
                            'Done',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: tempDate,
                      maximumDate: DateTime.now(),
                      minimumYear: 1940,
                      maximumYear: DateTime.now().year,
                      onDateTimeChanged: (newDate) {
                        tempDate = newDate;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Stage 3: Storytelling Welcome Transition ──────────────────────────────
  Widget _buildWelcomeStage(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A0A2E);

    // Staggered animation for the user's name:
    // Starts fading and sliding in only after the Welcome vector has settled
    final nameFade = CurvedAnimation(
      parent: _welcomeAnimCtrl,
      curve: const Interval(0.50, 0.95, curve: Curves.easeOutCubic),
    );
    final nameSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _welcomeAnimCtrl,
      curve: const Interval(0.50, 0.95, curve: Curves.easeOutBack),
    ));

    return Center(
      key: const ValueKey('welcome_stage'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Apple Rainbow Cursive "Welcome" Vector Graphic (Appears First)
            FadeTransition(
              opacity: _welcomeFade,
              child: ScaleTransition(
                scale: _welcomeScale,
                child: Container(
                  width: 320,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark
                                ? GlassTheme.accentPrimary
                                : const Color(0xFF7C4DFF))
                            .withValues(alpha: isDark ? 0.20 : 0.10),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/welcome.svg',
                      width: 280,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // 2. User Name Typography (Appears sequentially after "Welcome")
            SlideTransition(
              position: nameSlide,
              child: FadeTransition(
                opacity: nameFade,
                child: Text(
                  _savedName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
