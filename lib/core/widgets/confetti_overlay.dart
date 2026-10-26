import 'dart:math';
import 'package:flutter/material.dart';

/// Lightweight, 60fps canvas confetti explosion for celebrations
class ConfettiOverlay extends StatefulWidget {
  final VoidCallback onFinished;

  const ConfettiOverlay({super.key, required this.onFinished});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final List<_Particle> _particles = [];
  final Random _rng = Random();

  static const List<Color> _colors = [
    Color(0xFF007AFF), // Apple Blue
    Color(0xFF34C759), // Apple Green
    Color(0xFFFF9500), // Orange
    Color(0xFFFF2D55), // Pink
    Color(0xFFAF52DE), // Purple
    Color(0xFFFFCC00), // Gold
    Color(0xFF5856D6), // Indigo
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Generate ~50 physics confetti particles
    for (int i = 0; i < 55; i++) {
      final angle = _rng.nextDouble() * pi * 2;
      final speed = 250 + _rng.nextDouble() * 450;
      _particles.add(
        _Particle(
          color: _colors[_rng.nextInt(_colors.length)],
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 200, // burst slightly upward
          size: 6 + _rng.nextDouble() * 7,
          rotation: _rng.nextDouble() * pi * 2,
          rotationSpeed: (_rng.nextDouble() - 0.5) * 12,
          isCircle: _rng.nextBool(),
        ),
      );
    }

    _ctrl.forward().then((_) {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          final opacity = (1.0 - (t - 0.55).clamp(0.0, 0.45) / 0.45).clamp(0.0, 1.0);
          return Opacity(
            opacity: opacity,
            child: CustomPaint(
              size: Size.infinite,
              painter: _ConfettiPainter(
                particles: _particles,
                progress: t,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  final Color color;
  final double vx;
  final double vy;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final bool isCircle;

  _Particle({
    required this.color,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.isCircle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.42;
    const gravity = 550.0; // px/s^2

    final dt = progress * 1.8; // simulated time elapsed

    for (final p in particles) {
      final x = cx + p.vx * dt * 0.7;
      final y = cy + p.vy * dt * 0.7 + 0.5 * gravity * dt * dt;
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
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
