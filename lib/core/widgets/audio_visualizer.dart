import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A real-time circular waveform / pulse visualizer.
///
/// Driven by [amplitude] (0–1, the current tone output) and a continuously
/// running clock so the wave animates even at a steady tone. Color follows the
/// active ear via [color].
class AudioVisualizer extends StatefulWidget {
  const AudioVisualizer({
    super.key,
    required this.amplitude,
    required this.color,
    this.size = 220,
    this.frequency = 1000,
  });

  /// Current output amplitude, 0–1.
  final double amplitude;
  final Color color;
  final double size;

  /// Tone frequency in Hz — modulates the visual wave density.
  final double frequency;

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat();

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) {
          return CustomPaint(
            painter: _VisualizerPainter(
              t: _clock.value,
              amplitude: widget.amplitude,
              color: widget.color,
              frequency: widget.frequency,
            ),
          );
        },
      ),
    );
  }
}

class _VisualizerPainter extends CustomPainter {
  _VisualizerPainter({
    required this.t,
    required this.amplitude,
    required this.color,
    required this.frequency,
  });

  final double t;
  final double amplitude;
  final Color color;
  final double frequency;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final baseRadius = size.width * 0.28;
    final phase = t * 2 * math.pi;

    // Concentric pulsing rings expand outward with amplitude.
    for (var i = 0; i < 3; i++) {
      final progress = (t + i / 3) % 1.0;
      final radius = baseRadius + progress * size.width * 0.22 * (0.4 + amplitude);
      final opacity = (1 - progress) * 0.5 * (0.3 + amplitude);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color.withValues(alpha: opacity.clamp(0, 1)),
      );
    }

    // Circular waveform — radius modulated by a sine driven by frequency.
    final lobes = (frequency / 250).clamp(4, 24).toDouble();
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          color,
          color.withValues(alpha: 0.4),
          color,
        ],
        transform: GradientRotation(phase),
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius));

    final path = Path();
    const steps = 120;
    for (var i = 0; i <= steps; i++) {
      final angle = (i / steps) * 2 * math.pi;
      final wobble =
          math.sin(angle * lobes + phase) * baseRadius * 0.12 * (0.2 + amplitude);
      final r = baseRadius + wobble;
      final p = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, wavePaint);

    // Glowing core whose size tracks amplitude.
    final coreRadius = baseRadius * (0.45 + amplitude * 0.3);
    canvas.drawCircle(
      center,
      coreRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.9),
            color.withValues(alpha: 0.1),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: coreRadius)),
    );
  }

  @override
  bool shouldRepaint(_VisualizerPainter old) =>
      old.t != t ||
      old.amplitude != amplitude ||
      old.color != color ||
      old.frequency != frequency;
}
