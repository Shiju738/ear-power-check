import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../app.dart';
import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_background.dart';
import '../test/ear_test_screen.dart';

/// Landing screen: greeting, hero "start test" card, and a staggered grid of
/// feature cards with a theme toggle.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(isDark: isDark),
                const SizedBox(height: 24),
                _HeroCard()
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 24),
                Text(
                  'Explore',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 14),
                _FeatureGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const AppLogo(size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good to see you',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.lightTextSecondary),
              ),
              Text(
                'Ear Power Check',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        _ThemeToggle(isDark: isDark),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(10),
      borderRadius: 16,
      onTap: () {
        HapticFeedback.lightImpact();
        AppScope.of(context).themeController.toggle(isDark);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
          color: isDark ? AppColors.warning : AppColors.deepBlue,
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradient: AppColors.primaryGradient,
      padding: const EdgeInsets.all(24),
      onTap: () => context.pushFade(const EarTestScreen()),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Start a hearing check',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Put on your headphones and find a quiet spot.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Begin',
                        style: TextStyle(
                          color: AppColors.deepBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded,
                          color: AppColors.deepBlue, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const _PulsingHeadphones(),
        ],
      ),
    );
  }
}

class _PulsingHeadphones extends StatelessWidget {
  const _PulsingHeadphones();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.18),
      ),
      child: const Icon(Icons.headphones_rounded,
          color: Colors.white, size: 40),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          duration: 1400.ms,
          begin: const Offset(1, 1),
          end: const Offset(1.12, 1.12),
          curve: Curves.easeInOut,
        );
  }
}

class _Feature {
  const _Feature(this.title, this.subtitle, this.icon, this.gradient,
      this.onTap);
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final void Function(BuildContext) onTap;
}

class _FeatureGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void soon(BuildContext c) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(c).showSnackBar(
        const SnackBar(content: Text('Coming soon in this build')),
      );
    }

    final features = <_Feature>[
      _Feature('Manual Test', 'Sweep each tone', Icons.tune_rounded,
          AppColors.leftEarGradient, (c) => c.pushFade(const EarTestScreen())),
      _Feature('Automatic', 'Hands-free scan', Icons.auto_awesome_rounded,
          AppColors.accentGradient, soon),
      _Feature('Audiogram', 'See your graph', Icons.show_chart_rounded,
          AppColors.successGradient, soon),
      _Feature('History', 'Past results', Icons.history_rounded,
          AppColors.rightEarGradient, soon),
    ];

    return AnimationLimiter(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.05,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 500),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 40,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            for (final f in features) _FeatureCard(feature: f),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});
  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      onTap: () => feature.onTap(context),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: feature.gradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(feature.icon, color: Colors.white, size: 26),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                feature.subtitle,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.lightTextSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
