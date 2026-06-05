import 'package:flutter/material.dart';

/// Custom page route builders so the app never uses default Flutter platform
/// transitions. Combines fade + slide + a subtle scale for a premium feel.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required this.page,
    this.direction = AxisDirection.up,
  }) : super(
          transitionDuration: const Duration(milliseconds: 480),
          reverseTransitionDuration: const Duration(milliseconds: 380),
          pageBuilder: (_, _, _) => page,
          transitionsBuilder: (context, animation, secondary, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final beginOffset = switch (direction) {
              AxisDirection.up => const Offset(0, 0.08),
              AxisDirection.down => const Offset(0, -0.08),
              AxisDirection.left => const Offset(0.12, 0),
              AxisDirection.right => const Offset(-0.12, 0),
            };

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween(begin: beginOffset, end: Offset.zero)
                    .animate(curved),
                child: ScaleTransition(
                  scale: Tween(begin: 0.98, end: 1.0).animate(curved),
                  child: child,
                ),
              ),
            );
          },
        );

  final Widget page;
  final AxisDirection direction;
}

/// Convenience helpers for navigation with the custom transition.
extension AppNavigation on BuildContext {
  Future<T?> pushFade<T>(Widget page,
      {AxisDirection direction = AxisDirection.up}) {
    return Navigator.of(this)
        .push<T>(AppPageRoute<T>(page: page, direction: direction));
  }

  Future<T?> pushReplacementFade<T>(Widget page,
      {AxisDirection direction = AxisDirection.up}) {
    return Navigator.of(this).pushReplacement(
      AppPageRoute<T>(page: page, direction: direction),
    );
  }
}
