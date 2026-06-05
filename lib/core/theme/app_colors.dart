import 'package:flutter/material.dart';

/// Central color palette for the premium medical-grade design.
///
/// Defines brand, accent, surface and semantic colors plus the signature
/// gradients used across glass cards, buttons and backgrounds.
class AppColors {
  AppColors._();

  // ---- Brand / Primary ----
  static const Color deepBlue = Color(0xFF2563EB);
  static const Color cyan = Color(0xFF06B6D4);

  // ---- Accent ----
  static const Color emerald = Color(0xFF10B981);
  static const Color purple = Color(0xFF8B5CF6);

  // ---- Backgrounds ----
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color darkBg = Color(0xFF0F172A);

  // ---- Semantic ----
  static const Color success = emerald;
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // ---- Ear identity colors ----
  static const Color leftEar = cyan;
  static const Color rightEar = purple;

  // ---- Surfaces (light) ----
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceAlt = Color(0xFFEFF4FB);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // ---- Surfaces (dark) ----
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceAlt = Color(0xFF162033);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // ---- Signature gradients ----
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [deepBlue, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [purple, deepBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [emerald, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient leftEarGradient = LinearGradient(
    colors: [cyan, deepBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rightEarGradient = LinearGradient(
    colors: [purple, Color(0xFFD946EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Ambient background gradient behind frosted-glass surfaces.
  static const LinearGradient lightBackdrop = LinearGradient(
    colors: [Color(0xFFEAF2FF), Color(0xFFF8FAFC), Color(0xFFEDFBFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBackdrop = LinearGradient(
    colors: [Color(0xFF0B1220), Color(0xFF0F172A), Color(0xFF12253B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Color for a given ear side.
  static Color ear(bool isLeft) => isLeft ? leftEar : rightEar;

  static LinearGradient earGradient(bool isLeft) =>
      isLeft ? leftEarGradient : rightEarGradient;
}
