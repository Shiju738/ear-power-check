import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A frosted-glass surface with a subtle border, soft shadow and rounded
/// corners — the core building block of the premium UI.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = AppTheme.radiusLarge,
    this.blur = 18,
    this.onTap,
    this.gradient,
    this.tint,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final VoidCallback? onTap;

  /// Optional gradient overlay (used for highlighted / hero cards).
  final Gradient? gradient;

  /// Optional flat tint instead of the default translucent fill.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(borderRadius);

    final fill = tint ??
        (isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.55));

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.7);

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : const Color(0xFF94A3B8).withValues(alpha: 0.22),
            blurRadius: 30,
            spreadRadius: -6,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: Ink(
                decoration: BoxDecoration(
                  color: gradient == null ? fill : null,
                  gradient: gradient,
                  borderRadius: radius,
                  border: Border.all(color: borderColor, width: 1.2),
                ),
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
