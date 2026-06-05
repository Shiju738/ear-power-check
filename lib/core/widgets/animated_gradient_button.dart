import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// A premium primary button: gradient fill, scale-on-press micro-interaction,
/// haptic feedback and an optional leading icon.
class AnimatedGradientButton extends StatefulWidget {
  const AnimatedGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient = AppColors.primaryGradient,
    this.expand = true,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient gradient;
  final bool expand;
  final bool enabled;

  @override
  State<AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<AnimatedGradientButton> {
  bool _pressed = false;

  bool get _active => widget.enabled && widget.onPressed != null;

  void _setPressed(bool value) {
    if (!_active) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: _active ? 1 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: _active
              ? () {
                  HapticFeedback.mediumImpact();
                  widget.onPressed!.call();
                }
              : null,
          child: Container(
            width: widget.expand ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              boxShadow: [
                BoxShadow(
                  color: widget.gradient.colors.first.withValues(alpha: 0.45),
                  blurRadius: 24,
                  spreadRadius: -4,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize:
                  widget.expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
