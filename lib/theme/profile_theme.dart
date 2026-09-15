import 'package:flutter/material.dart';

import 'vector_colors.dart';

class ProfileTheme {
  static const heading = TextStyle(
    fontFamily: 'Cormorant Garamond',
    fontWeight: FontWeight.w600,
    fontSize: 29,
    height: 1.15,
    color: VectorColors.purpleDeep,
  );
  static final data = ThemeData(
    useMaterial3: true,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: VectorColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: VectorColors.purpleDeep,
      surface: VectorColors.surfaceWhite,
      surfaceTint: Colors.transparent,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontSize: 13,
        height: 1.6,
        color: VectorColors.purpleDeep,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: VectorColors.purpleDeep,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: VectorColors.inputBorder.withValues(alpha: .45),
      thickness: .7,
      space: 24,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: VectorColors.surfaceWhite,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: VectorColors.purpleDeep.withValues(alpha: .16),
          width: .8,
        ),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: VectorColors.surfaceWhite,
      surfaceTintColor: Colors.transparent,
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: VectorColors.surfaceWhite,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: VectorColors.purpleDeep.withValues(alpha: .2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: VectorColors.purpleDeep.withValues(alpha: .2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: VectorColors.purpleDeep, width: 1),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: VectorColors.purpleDeep),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: VectorColors.apricot,
        foregroundColor: VectorColors.purpleDeep,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
