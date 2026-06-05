import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app.dart';
import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/audio_visualizer.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_background.dart';
import 'controllers/ear_test_controller.dart';
import 'models/hearing_test_models.dart';
import 'results_screen.dart';

/// The manual hearing test: the user sweeps each tone's level to find the
/// faintest level they can still hear, per ear and frequency.
class EarTestScreen extends StatefulWidget {
  const EarTestScreen({super.key});

  @override
  State<EarTestScreen> createState() => _EarTestScreenState();
}

class _EarTestScreenState extends State<EarTestScreen> {
  late final EarTestController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EarTestController(AppScope.of(context).tonePlayer);
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.start());
    _controller.addListener(_onChange);
  }

  void _onChange() {
    if (_controller.finished && mounted) {
      _controller.removeListener(_onChange);
      final result = _controller.buildResult(DateTime.now());
      context.pushReplacementFade(ResultsScreen(result: result));
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              if (_controller.finished) {
                return const Center(child: CircularProgressIndicator());
              }
              final step = _controller.current;
              final earColor = AppColors.ear(step.ear.isLeft);
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    _TopBar(controller: _controller),
                    const SizedBox(height: 8),
                    _EarIndicators(activeEar: step.ear),
                    const Spacer(),
                    ValueListenableBuilder<double>(
                      valueListenable: _controller.output,
                      builder: (context, amp, _) => AudioVisualizer(
                        amplitude: amp,
                        color: earColor,
                        frequency: step.frequencyHz.toDouble(),
                        size: 240,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${step.frequencyHz} Hz',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ).animate(key: ValueKey(step.frequencyHz)).fadeIn().slideY(
                          begin: 0.3,
                          end: 0,
                          curve: Curves.easeOutCubic,
                        ),
                    Text(
                      '${step.ear.label} ear · tone ${_controller.index + 1} of ${_controller.total}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.lightTextSecondary,
                          ),
                    ),
                    const Spacer(),
                    _LevelControls(controller: _controller, earColor: earColor),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});
  final EarTestController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(10),
          borderRadius: 14,
          onTap: () => Navigator.of(context).maybePop(),
          child: const Icon(Icons.close_rounded),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: controller.progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.deepBlue),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '${(controller.progress * 100).round()}%',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _EarIndicators extends StatelessWidget {
  const _EarIndicators({required this.activeEar});
  final Ear activeEar;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _EarChip(ear: Ear.left, active: activeEar.isLeft),
        const SizedBox(width: 16),
        _EarChip(ear: Ear.right, active: !activeEar.isLeft),
      ],
    );
  }
}

class _EarChip extends StatelessWidget {
  const _EarChip({required this.ear, required this.active});
  final Ear ear;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.ear(ear.isLeft);
    return AnimatedScale(
      scale: active ? 1.05 : 0.92,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: active ? AppColors.earGradient(ear.isLeft) : null,
          color: active ? null : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 24,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              ear.isLeft ? Icons.hearing_rounded : Icons.hearing_rounded,
              color: active ? Colors.white : color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '${ear.label} ear',
              style: TextStyle(
                color: active ? Colors.white : color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelControls extends StatelessWidget {
  const _LevelControls({required this.controller, required this.earColor});
  final EarTestController controller;
  final Color earColor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.volume_down_rounded,
                  color: AppColors.lightTextSecondary),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    activeTrackColor: earColor,
                    thumbColor: earColor,
                    overlayColor: earColor.withValues(alpha: 0.15),
                    inactiveTrackColor:
                        earColor.withValues(alpha: 0.15),
                  ),
                  child: Slider(
                    value: controller.dbHl,
                    min: kMinDbHl,
                    max: kMaxDbHl,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      controller.setLevel(v);
                    },
                  ),
                ),
              ),
              Icon(Icons.volume_up_rounded,
                  color: AppColors.lightTextSecondary),
            ],
          ),
          Text(
            'Lower the volume until the tone is barely audible',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OutlineButton(
                  label: "Can't hear it",
                  icon: Icons.volume_off_rounded,
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    controller.confirmThreshold(inaudible: true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _FillButton(
                  label: 'I can barely hear it',
                  color: earColor,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    controller.confirmThreshold();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => controller.togglePlay(),
            icon: Icon(controller.isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded),
            label: Text(controller.isPlaying ? 'Pause tone' : 'Replay tone'),
          ),
        ],
      ),
    );
  }
}

class _FillButton extends StatelessWidget {
  const _FillButton(
      {required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton(
      {required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
