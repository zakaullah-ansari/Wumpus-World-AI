import 'dart:math';
import 'package:flutter/material.dart';

/// A lightweight celebratory confetti burst, implemented with a
/// `CustomPainter` driven by an `AnimationController` instead of a
/// third-party package — one more use of the CustomPainter + Animation
/// combo (Syllabus #2), this time for continuous particle motion rather
/// than a static badge.
class ConfettiOverlay extends StatefulWidget {
  final bool active;
  const ConfettiOverlay({super.key, required this.active});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    final random = Random();
    _particles = List.generate(50, (_) => _Particle(random));
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.repeat();
    } else if (!widget.active && oldWidget.active) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _ConfettiPainter(particles: _particles, progress: _controller.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Particle {
  final double startX;
  final double speed;
  final double size;
  final double phase;
  final Color color;

  _Particle(Random random)
      : startX = random.nextDouble(),
        speed = 0.6 + random.nextDouble() * 0.8,
        size = 4 + random.nextDouble() * 5,
        phase = random.nextDouble(),
        color = Colors.primaries[random.nextInt(Colors.primaries.length)];
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final t = (progress * particle.speed + particle.phase) % 1.0;
      final dx = particle.startX * size.width + sin(t * 2 * pi + particle.phase * 10) * 14;
      final dy = t * size.height;
      final paint = Paint()..color = particle.color.withOpacity((1 - t * 0.4).clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(t * 2 * pi * 3);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 1.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
