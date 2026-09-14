import 'package:flutter/material.dart';

import 'vector_colors.dart';

/// The Vector app type-scale.
///
/// Family is always "IBM Plex Sans Arabic", set via the plain `fontFamily`
/// string (never GoogleFonts / runtime font fetching). Every style defaults
/// its `color` to [VectorColors.textNeutral]; callers rendering on a
/// purple/dark surface should `.copyWith(color: VectorColors.textOnPurple)`.
class VectorText {
  VectorText._();

  static const String _family = 'IBM Plex Sans Arabic';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _family,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.5,
    color: VectorColors.textNeutral,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _family,
    fontSize: 27,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
    color: VectorColors.textNeutral,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _family,
    fontSize: 23,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: VectorColors.textNeutral,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: _family,
    fontSize: 19,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: VectorColors.textNeutral,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: VectorColors.textNeutral,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: VectorColors.textNeutral,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: VectorColors.textNeutral,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: VectorColors.textNeutral,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: VectorColors.textNeutral,
  );

  /// Presentation convention: this is used for UPPERCASE eyebrow/tag labels.
  /// Flutter's [TextStyle] cannot apply a text-transform, so callers are
  /// responsible for calling `.toUpperCase()` on the string themselves
  /// before rendering it with this style.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: VectorColors.textNeutral,
  );
}
