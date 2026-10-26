import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class BirthdayCelebrationModal extends StatefulWidget {
  final String userName;
  final DateTime? birthday;
  final VoidCallback onDismiss;

  const BirthdayCelebrationModal({
    super.key,
    required this.userName,
    this.birthday,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required String userName,
    DateTime? birthday,
    VoidCallback? onDismiss,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (ctx, anim1, anim2) {
        return BirthdayCelebrationModal(
          userName: userName,
          birthday: birthday,
          onDismiss: () {
            Navigator.of(ctx, rootNavigator: true).pop();
            onDismiss?.call();
          },
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  State<BirthdayCelebrationModal> createState() =>
      _BirthdayCelebrationModalState();
}

class _BirthdayCelebrationModalState extends State<BirthdayCelebrationModal>
    with TickerProviderStateMixin {
  late final AnimationController _cardGlowCtrl;
  late final Animation<double> _glowAnim;

  // Recurring confetti bursts every 3 seconds
  Timer? _confettiTimer;
  final List<_ConfettiBurst> _activeBursts = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();

    _cardGlowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _cardGlowCtrl, curve: Curves.easeInOut),
    );

    // Initial burst
    _spawnDualConfettiBurst();

    // Recurring bursts every 3 seconds
    _confettiTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        _spawnDualConfettiBurst();
      }
    });
  }

  void _spawnDualConfettiBurst() {
    HapticFeedback.mediumImpact();
    final burst = _ConfettiBurst(
      vsync: this,
      rng: _rng,
      onCompleted: (b) {
        if (mounted) {
          setState(() {
            _activeBursts.remove(b);
          });
        }
      },
    );
    setState(() {
      _activeBursts.add(burst);
    });
    burst.start();
  }

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) return 'th';
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String _buildBirthdayTitle() {
    final name = widget.userName.isNotEmpty ? widget.userName : 'Superstar';
    if (widget.birthday != null) {
      final now = DateTime.now();
      int age = now.year - widget.birthday!.year;
      // If birthday hasn't occurred yet this year
      if (now.month < widget.birthday!.month ||
          (now.month == widget.birthday!.month && now.day < widget.birthday!.day)) {
        age--;
      }
      if (age > 0) {
        final ordinal = _getOrdinalSuffix(age);
        return 'Happy $age$ordinal Birthday,\n$name!';
      }
    }
    return 'Happy Birthday,\n$name!';
  }

  @override
  void dispose() {
    _confettiTimer?.cancel();
    _cardGlowCtrl.dispose();
    for (final b in _activeBursts) {
      b.dispose();
    }
    _activeBursts.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient blurred frosted backdrop
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.20),
            ),
          ),

          // Confetti particle canvas layer (full screen)
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                fit: StackFit.expand,
                children: _activeBursts.map((b) => b.buildWidget()).toList(),
              ),
            ),
          ),

          // Centered iOS Glass Birthday Card
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedBuilder(
                animation: _glowAnim,
                builder: (context, _) {
                  return Container(
                    constraints: const BoxConstraints(maxWidth: 380),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        // Soft breathing outer neon aura
                        BoxShadow(
                          color: const Color(0xFFFF2D55)
                              .withValues(alpha: 0.25 * _glowAnim.value),
                          blurRadius: 40,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: const Color(0xFF007AFF)
                              .withValues(alpha: 0.20 * _glowAnim.value),
                          blurRadius: 45,
                          spreadRadius: 2,
                          offset: const Offset(0, -6),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 30,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(26, 22, 26, 26),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      const Color(0xFF2C2C2E)
                                          .withValues(alpha: 0.88),
                                      const Color(0xFF1C1C1E)
                                          .withValues(alpha: 0.94),
                                    ]
                                  : [
                                      Colors.white.withValues(alpha: 0.92),
                                      const Color(0xFFF2F2F7)
                                          .withValues(alpha: 0.96),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.20)
                                  : Colors.white.withValues(alpha: 0.70),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Top Bar: Real DEDO typography logo on top-left, close on top-right
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Real DEDO Typography Brand Logo (Identical to HomeScreen)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'DEDO',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1A0A2E),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Close button
                                  GestureDetector(
                                    onTap: widget.onDismiss,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: (isDark
                                                ? Colors.white
                                                : Colors.black)
                                            .withValues(alpha: 0.08),
                                      ),
                                      child: Icon(
                                        CupertinoIcons.xmark,
                                        size: 15,
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.65)
                                            : Colors.black.withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 22),

                              // Festive 3D Cake / Gift Icon with glowing halo
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF2D55),
                                      Color(0xFFFF9500),
                                      Color(0xFFFFCC00),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF2D55)
                                          .withValues(alpha: 0.40),
                                      blurRadius: 22,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    '🎂',
                                    style: TextStyle(fontSize: 42),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // Dynamic Age Birthday Title
                              Text(
                                _buildBirthdayTitle(),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.6,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1C1C1E),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Heartfelt wishing message
                              Text(
                                'Wishing you a day full of celebration, happiness, and another incredible year of growth, focus, and achieving all your dreams! ✨',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.45,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.65)
                                      : const Color(0xFF48484A),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Premium fluid Thank You / Celebrate button
                              GestureDetector(
                                onTap: widget.onDismiss,
                                child: Container(
                                  width: double.infinity,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF007AFF),
                                        Color(0xFF5856D6),
                                        Color(0xFFAF52DE),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF007AFF)
                                            .withValues(alpha: 0.35),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Thank You, Dedo! 🎉',
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dual-Cannon Multi-Colored 3-Second Confetti Burst ────────────────────────

class _ConfettiBurst {
  final TickerProvider vsync;
  final Random rng;
  final void Function(_ConfettiBurst) onCompleted;
  late final AnimationController _ctrl;
  final List<_ConfettiParticle> _particles = [];

  static const List<Color> _palette = [
    Color(0xFFFF2D55), // iOS Pink/Red
    Color(0xFFFF9500), // Orange
    Color(0xFFFFCC00), // Gold
    Color(0xFF34C759), // Green
    Color(0xFF007AFF), // Blue
    Color(0xFF5856D6), // Indigo
    Color(0xFFAF52DE), // Violet
    Color(0xFF00C7BE), // Teal
  ];

  _ConfettiBurst({
    required this.vsync,
    required this.rng,
    required this.onCompleted,
  }) {
    _ctrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 2800),
    );

    // Create 70 confetti pieces bursting from bottom-left and bottom-right
    for (int i = 0; i < 70; i++) {
      final isLeft = i.isEven;
      final angle = isLeft
          ? -pi / 4 - (rng.nextDouble() * 0.35) // Launch upward-right
          : -3 * pi / 4 + (rng.nextDouble() * 0.35); // Launch upward-left
      final speed = 650.0 + rng.nextDouble() * 550.0;

      _particles.add(
        _ConfettiParticle(
          color: _palette[rng.nextInt(_palette.length)],
          isLeftOrigin: isLeft,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          size: 7.0 + rng.nextDouble() * 8.0,
          rotation: rng.nextDouble() * pi * 2,
          rotationSpeed: (rng.nextDouble() - 0.5) * 16,
          isCircle: rng.nextDouble() < 0.35,
        ),
      );
    }

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onCompleted(this);
      }
    });
  }

  void start() => _ctrl.forward();

  void dispose() => _ctrl.dispose();

  Widget buildWidget() {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        final opacity = (1.0 - (t - 0.65).clamp(0.0, 0.35) / 0.35).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: CustomPaint(
            size: Size.infinite,
            painter: _DualBurstPainter(
              particles: _particles,
              progress: t,
            ),
          ),
        );
      },
    );
  }
}

class _ConfettiParticle {
  final Color color;
  final bool isLeftOrigin;
  final double vx;
  final double vy;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final bool isCircle;

  _ConfettiParticle({
    required this.color,
    required this.isLeftOrigin,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.isCircle,
  });
}

class _DualBurstPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _DualBurstPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const gravity = 780.0; // Gravity pulling downward
    final dt = progress * 2.5;

    final leftOrigin = Offset(size.width * 0.08, size.height * 0.95);
    final rightOrigin = Offset(size.width * 0.92, size.height * 0.95);

    for (final p in particles) {
      final origin = p.isLeftOrigin ? leftOrigin : rightOrigin;
      final x = origin.dx + p.vx * dt * 0.6;
      final y = origin.dy + p.vy * dt * 0.6 + 0.5 * gravity * dt * dt;
      final rot = p.rotation + p.rotationSpeed * dt;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);

      final paint = Paint()..color = p.color;

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero, width: p.size, height: p.size * 0.5),
            const Radius.circular(2.5),
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _DualBurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
