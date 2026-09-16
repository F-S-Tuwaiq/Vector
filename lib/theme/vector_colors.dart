import 'package:flutter/material.dart';

/// Single source of truth for every color used across the Vector app.
///
/// Hard rule: no inline hex colors anywhere else in the app — every color
/// reference must go through [VectorColors]. If a color is not a token
/// defined here, it does not exist.
class VectorColors {
  VectorColors._();

  // Purples ------------------------------------------------------------
  static const Color purpleDeep = Color(0xFF3F2449);
  static const Color purpleBrand = Color(0xFF493252);
  static const Color purpleSurfaceLight = Color(0xFF4A3054);
  static const Color purpleSurfaceEnd = Color(0xFF4B3156);

  // Accent (single warm accent used across the whole app) --------------
  static const Color apricot = Color(0xFFF2B880);
  static const Color buttonStart = Color(0xFFF8C386);
  static const Color buttonEnd = Color(0xFFF4AF60);

  // Backgrounds / surfaces ----------------------------------------------
  static const Color background = Color(0xFFF7F4F8);
  static const Color backgroundLight = Color(0xFFF9F6FB);
  static const Color backgroundWarm = Color(0xFFFBF8FC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceLavender = Color(0xFFE5D8EE);

  // Text ------------------------------------------------------------------
  static const Color textPrimary = Color(0xFF3F2449);
  static const Color textNeutral = Color(0xFF29232E);
  static const Color textSecondary = Color(0xFF6F6478);
  static const Color textMuted = Color(0xFF9A90A2);
  static const Color textSecondaryPurple = Color(0xFF826891);
  static const Color textOnPurple = Color(0xFFF7F4F8);

  // Inputs ------------------------------------------------------------------
  static const Color inputBorder = Color(0xFFD0BDE2);
  static const Color inputFocus = Color(0xFF826891);

  // Misc ------------------------------------------------------------------
  static const Color linkWarm = Color(0xFF963C1A);
  static const Color error = Color(0xFFAC5747);

  // Brand loader (V-logo loading animation) ------------------------------
  // The loader background uses [purpleBrand] (the app's main purple) —
  // only the mark's own stroke colors are spec-exact and distinct from
  // the rest of the palette.
  static const Color loaderWhite = Color(0xFFF4F2F6);
  static const Color loaderOrange = Color(0xFFEFA96B);

  // Skeleton loaders (shimmer placeholders for data reads) ----------------
  static const Color skeletonBase = Color(0xFFE7E1EC);
  static const Color skeletonHighlight = Color(0xFFF3EFF6);

  // Derived (non-const) colors ------------------------------------------
  /// Hairline border color used INSTEAD of drop shadows everywhere
  /// (cards, dialogs, chips, etc.) — a 1px border in place of elevation.
  static final Color hairline = const Color(0xFF29232E).withValues(alpha: 0.08);

  /// Scrim behind dialogs / bottom sheets.
  static final Color dialogBarrier = const Color(0xFF29232E).withValues(alpha: 0.55);

  /// Primary accent-button fill: gradient from [buttonStart] to [buttonEnd].
  /// Used for the app's main call-to-action buttons (see Section 2.4).
  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [buttonStart, buttonEnd],
  );
}
