import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A lightweight, dependency-free confetti burst painted with [CustomPainter].
/// Plays once on mount.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key, this.pieces = 80});
  final int pieces;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  late final List<_Particle> _particles = _build(widget.pieces);

  // Deterministic pseudo-random so we avoid Math.random restrictions and keep
  // a stable layout across rebuilds.
  List<_Particle> _build(int n) {
    const colors = [
      AppColors.cyan,
      AppColors.purple,
      AppColors.emerald,
      AppColors.deepBlue,
      AppColors.warning,
    ];
    return List.generate(n, (i) {
      final seed = (i * 2654435761) & 0xFFFFFFFF;
      double rnd(int shift) =>
          ((seed >> shift) & 0xFF) / 255.0;
      return _Particle(
        x: rnd(0),
        delay: rnd(8) * 0.3,
        speed: 0.6 + rnd(16) * 0.8,
        drift: (rnd(24) - 0.5) * 0.4,
        size: 6 + rnd(4) * 8,
        color: colors[i % colors.length],
        rotations: 1 + rnd(12) * 4,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_particles, _controller.value),
        ),
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.delay,
    required this.speed,
    required this.drift,
    required this.size,
    required this.color,
    required this.rotations,
  });
  final double x, delay, speed, drift, size, rotations;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.t);
  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final y = (local * p.speed) * (size.height + 60) - 40;
      final x = p.x * size.width +
          math.sin(local * math.pi * 2 * p.rotations) * p.drift * 60;
      final opacity = (1 - local).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(local * math.pi * 2 * p.rotations);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(2),
        ),
        Paint()..color = p.color.withValues(alpha: opacity),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
