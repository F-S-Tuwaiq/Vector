import 'package:flutter/material.dart';

import 'vector_colors.dart';
import 'vector_text.dart';

class VectorTheme {
  VectorTheme._();

  static const double _buttonRadius = 13;
  static const double _cardRadius = 21;
  static const double _buttonHeight = 52;

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: VectorColors.purpleBrand),
    scaffoldBackgroundColor: VectorColors.background,
    fontFamily: 'IBM Plex Sans Arabic',
    textTheme: const TextTheme(
      displayLarge: VectorText.displayLarge,
      headlineLarge: VectorText.headlineLarge,
      headlineMedium: VectorText.headlineMedium,
      titleLarge: VectorText.titleLarge,
      titleMedium: VectorText.titleMedium,
      bodyLarge: VectorText.bodyLarge,
      bodyMedium: VectorText.bodyMedium,
      labelLarge: VectorText.labelLarge,
      labelMedium: VectorText.labelMedium,
      labelSmall: VectorText.labelSmall,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: VectorColors.surfaceWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        side: BorderSide(color: VectorColors.hairline),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: VectorColors.purpleBrand,
        foregroundColor: VectorColors.textOnPurple,
        minimumSize: const Size.fromHeight(_buttonHeight),
        textStyle: VectorText.labelLarge.copyWith(
          color: VectorColors.textOnPurple,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: VectorColors.purpleBrand,
        foregroundColor: VectorColors.textOnPurple,
        minimumSize: const Size.fromHeight(_buttonHeight),
        textStyle: VectorText.labelLarge.copyWith(
          color: VectorColors.textOnPurple,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: VectorColors.purpleBrand,
        minimumSize: const Size.fromHeight(_buttonHeight),
        side: BorderSide(color: VectorColors.hairline),
        textStyle: VectorText.labelLarge.copyWith(
          color: VectorColors.purpleBrand,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: VectorColors.purpleBrand,
        textStyle: VectorText.labelLarge.copyWith(
          color: VectorColors.purpleBrand,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: VectorColors.surfaceWhite,
      hintStyle: VectorText.bodyLarge.copyWith(color: VectorColors.textMuted),
      labelStyle: VectorText.bodyLarge.copyWith(
        color: VectorColors.textSecondary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: BorderSide(color: VectorColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: BorderSide(color: VectorColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: BorderSide(color: VectorColors.inputFocus, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: BorderSide(color: VectorColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: BorderSide(color: VectorColors.error, width: 1.5),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide.none,
      backgroundColor: VectorColors.surfaceLavender,
      labelStyle: VectorText.labelMedium.copyWith(
        color: VectorColors.textSecondaryPurple,
      ),
      selectedColor: VectorColors.apricot,
      secondarySelectedColor: VectorColors.apricot,
      disabledColor: VectorColors.surfaceLavender,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: VectorColors.surfaceWhite,
      surfaceTintColor: Colors.transparent,
      barrierColor: VectorColors.dialogBarrier,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        side: BorderSide(color: VectorColors.hairline),
      ),
    ),
  );
}
