import 'package:flutter/material.dart';

/// Single source of truth for every color used across the Vector app.
/// Sampled from the approved brand mockup — do not inline hex values
/// in widgets; reference these tokens instead.
class VectorColors {
  VectorColors._();

  // Primary purples
  static const Color purpleDeep = Color(0xFF3F2449);
  static const Color purpleBrand = Color(0xFF493252);
  static const Color purpleSurfaceLight = Color(0xFF4A3054);
  static const Color purpleSurfaceEnd = Color(0xFF4B3156);

  // Accent — the single warm accent
  static const Color apricot = Color(0xFFF2B880);
  static const Color buttonStart = Color(0xFFF8C386);
  static const Color buttonEnd = Color(0xFFF4AF60);

  // Backgrounds & surfaces
  static const Color background = Color(0xFFF7F4F8);
  static const Color backgroundLight = Color(0xFFF9F6FB);
  static const Color backgroundWarm = Color(0xFFFBF8FC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceLavender = Color(0xFFE5D8EE);

  // Text & borders
  static const Color textPrimary = Color(0xFF3F2449);
  static const Color textNeutral = Color(0xFF29232E);
  static const Color textSecondary = Color(0xFF6F6478);
  static const Color textMuted = Color(0xFF9A90A2);
  static const Color textSecondaryPurple = Color(0xFF826891);
  static const Color textOnPurple = Color(0xFFF7F4F8);
  static const Color inputBorder = Color(0xFFD0BDE2);
  static const Color inputFocus = Color(0xFF826891);
  static const Color linkWarm = Color(0xFF963C1A);
  static final Color hairline = textNeutral.withValues(alpha: 0.08);

  // Error
  static const Color error = Color(0xFFAC5747);

  static const LinearGradient accentButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [buttonStart, buttonEnd],
  );
}
