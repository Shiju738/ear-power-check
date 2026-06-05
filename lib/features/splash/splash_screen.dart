import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/gradient_background.dart';
import '../home/home_screen.dart';

/// Animated splash: logo reveal with pulse, scale and fade, then an automatic
/// transition into the home screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void initState() {
    super.initState();
    _goHomeAfterDelay();
  }

  Future<void> _goHomeAfterDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    context.pushReplacementFade(const HomeScreen());
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing glow ring behind the logo.
              AnimatedBuilder(
                animation: _wave,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.cyan.withValues(alpha: 0.25),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: child,
                  );
                },
                child: AnimatedBuilder(
                  animation: _wave,
                  builder: (context, _) =>
                      AppLogo(size: 130, waveProgress: _wave.value),
                ),
              )
                  .animate()
                  .scale(
                    duration: 700.ms,
                    curve: Curves.easeOutBack,
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1, 1),
                  )
                  .fadeIn(duration: 600.ms)
                  .then()
                  .shimmer(duration: 1200.ms, color: Colors.white24),
              const SizedBox(height: 32),
              Text(
                'Ear Power',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
              ).animate().fadeIn(delay: 500.ms, duration: 700.ms).slideY(
                    begin: 0.4,
                    end: 0,
                    curve: Curves.easeOutCubic,
                  ),
              const SizedBox(height: 8),
              Text(
                'Premium hearing check',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightTextSecondary,
                    ),
              ).animate().fadeIn(delay: 800.ms, duration: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
