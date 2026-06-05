import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The app's brand mark: a stylized ear with emanating sound waves, painted in
/// the primary gradient. Used on the splash and home screens.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 120, this.waveProgress = 1});

  final double size;

  /// 0–1 reveal of the sound waves (for splash animation).
  final double waveProgress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter(waveProgress)),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.waveProgress);
  final double waveProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shader = AppColors.primaryGradient.createShader(rect);
    final stroke = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.075
      ..strokeCap = StrokeCap.round;

    final center = size.center(Offset.zero);

    // Ear shape (a spiral-ish curve).
    final earPath = Path();
    final r = size.width * 0.26;
    earPath.addArc(
      Rect.fromCircle(center: center.translate(-size.width * 0.04, 0), radius: r),
      -math.pi * 0.55,
      math.pi * 1.5,
    );
    // Inner hook of the ear.
    earPath.moveTo(center.dx - size.width * 0.04, center.dy + r * 0.55);
    earPath.quadraticBezierTo(
      center.dx + r * 0.3,
      center.dy + r * 0.4,
      center.dx + r * 0.2,
      center.dy - r * 0.1,
    );
    canvas.drawPath(earPath, stroke);

    // Sound waves emanating to the right, revealed by waveProgress.
    final waveCenter = center.translate(size.width * 0.18, 0);
    for (var i = 0; i < 3; i++) {
      final waveReveal = ((waveProgress * 3) - i).clamp(0.0, 1.0);
      if (waveReveal <= 0) continue;
      final radius = size.width * (0.12 + i * 0.1);
      final wavePaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.05
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: waveReveal);
      final sweep = (math.pi * 0.6) * waveReveal;
      canvas.drawArc(
        Rect.fromCircle(center: waveCenter, radius: radius),
        -sweep / 2,
        sweep,
        false,
        wavePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.waveProgress != waveProgress;
}
