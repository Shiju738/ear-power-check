import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_gradient_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_background.dart';
import '../home/home_screen.dart';
import 'ear_test_screen.dart';
import 'models/hearing_test_models.dart';
import 'widgets/audiogram_chart.dart';
import 'widgets/confetti_overlay.dart';

/// Shows the outcome of a hearing test: an animated score reveal, the grade,
/// per-ear summaries and the audiogram. Confetti plays for good results.
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.result});
  final HearingTestResult result;

  bool get _celebrate => result.grade.index <= HearingGrade.good.index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          GradientBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Your Results',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 24),
                    _ScoreReveal(result: result),
                    const SizedBox(height: 24),
                    _GradeCard(result: result),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _EarSummary(result: result, ear: Ear.left),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _EarSummary(result: result, ear: Ear.right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Audiogram',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Hearing threshold (dB HL) — lower is better',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AudiogramChart(result: result),
                          const SizedBox(height: 8),
                          const _Legend(),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 16),
                    const _Disclaimer(),
                    const SizedBox(height: 24),
                    AnimatedGradientButton(
                      label: 'Test again',
                      icon: Icons.refresh_rounded,
                      onPressed: () =>
                          context.pushReplacementFade(const EarTestScreen()),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.pushReplacementFade(
                          const HomeScreen(),
                          direction: AxisDirection.down),
                      child: const Text('Back to home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_celebrate)
            const Positioned.fill(child: ConfettiOverlay()),
        ],
      ),
    );
  }
}

class _ScoreReveal extends StatelessWidget {
  const _ScoreReveal({required this.result});
  final HearingTestResult result;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: result.score.toDouble()),
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(200, 200),
                painter: _ScoreRingPainter(value / 100),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value.round().toString(),
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                  ),
                  Text(
                    'EAR POWER',
                    style: TextStyle(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ).animate().scale(
          duration: 600.ms,
          curve: Curves.easeOutBack,
          begin: const Offset(0.7, 0.7),
          end: const Offset(1, 1),
        );
  }
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..color = AppColors.deepBlue.withValues(alpha: 0.12),
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..shader = AppColors.primaryGradient.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) => old.progress != progress;
}

class _GradeCard extends StatelessWidget {
  const _GradeCard({required this.result});
  final HearingTestResult result;

  @override
  Widget build(BuildContext context) {
    final grade = result.grade;
    final theme = Theme.of(context);
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: _celebrate(grade)
                  ? AppColors.successGradient
                  : AppColors.accentGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _celebrate(grade)
                  ? Icons.check_circle_rounded
                  : Icons.info_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grade.title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  grade.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0);
  }

  bool _celebrate(HearingGrade g) => g.index <= HearingGrade.good.index;
}

class _EarSummary extends StatelessWidget {
  const _EarSummary({required this.result, required this.ear});
  final HearingTestResult result;
  final Ear ear;

  @override
  Widget build(BuildContext context) {
    final pta = result.ptaForEar(ear);
    final color = AppColors.ear(ear.isLeft);
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text('${ear.label} ear',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${pta.round()}',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800, color: color),
          ),
          Text(
            'dB HL average',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.15, end: 0);
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(AppColors.leftEar, 'Left'),
        const SizedBox(width: 20),
        _dot(AppColors.rightEar, 'Right'),
      ],
    );
  }

  Widget _dot(Color color, String label) => Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      );
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.medical_information_outlined,
            size: 16, color: AppColors.lightTextSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'This is a self-screening, not a medical diagnosis. Results depend '
            'on your headphones and surroundings. See an audiologist for a '
            'clinical evaluation.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.lightTextSecondary,
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }
}
