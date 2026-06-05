import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Full-screen animated ambient backdrop: a soft gradient with two slowly
/// drifting colored "blobs" that give the glass surfaces something to refract.
class GradientBackground extends StatefulWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 14))
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkBackdrop : AppColors.lightBackdrop,
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value * 2 * math.pi;
          return Stack(
            children: [
              _blob(
                color: AppColors.cyan.withValues(alpha: isDark ? 0.28 : 0.32),
                alignment: Alignment(
                  0.8 * math.cos(t),
                  -0.7 + 0.25 * math.sin(t),
                ),
              ),
              _blob(
                color:
                    AppColors.purple.withValues(alpha: isDark ? 0.26 : 0.28),
                alignment: Alignment(
                  -0.8 * math.cos(t * 0.8),
                  0.7 + 0.2 * math.sin(t * 1.2),
                ),
              ),
              ?child,
            ],
          );
        },
        child: widget.child,
      ),
    );
  }

  Widget _blob({required Color color, required Alignment alignment}) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
