import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const purple = Color(0xFF3F2449);
  static const purpleDeep = Color(0xFF23142C);
  static const purpleMid = Color(0xFF4A3054);
  static const purpleLight = Color(0xFF4B3156);
  static const background = Color(0xFFF7F4F8);
  static const backgroundBright = Color(0xFFF9F6FB);
  static const backgroundSoft = Color(0xFFF7F3FA);
  static const backgroundWhite = Color(0xFFFBF8FC);
  static const surfaceWhite = Color(0xFFFDFBFE);
  static const lavender = Color(0xFFE5D8EE);
  static const lavenderLight = Color(0xFFE1D3EB);
  static const lavenderMid = Color(0xFFB298C0);
  static const lavenderDeep = Color(0xFFB99FC6);
  static const lavenderTriangle = Color(0xFFCBB7DE);
  static const apricot = Color(0xFFF2B880);
  static const apricotBright = Color(0xFFF7C17D);
  static const apricotButtonStart = Color(0xFFF8C386);
  static const apricotButtonEnd = Color(0xFFF4AF60);
  static const muted = Color(0xFF826891);
  static const mutedDeep = Color(0xFF715080);
  static const secondary = Color(0xFF963C1A);
  static const fieldBorder = Color(0xFFD0BDE2);
  static const fieldFocused = Color(0xFF826891);
  static const fieldError = Color(0xFFAC5747);
  static const textPrimary = Color(0xFF3F2449);
}

abstract final class AppTypography {
  static TextStyle sans({
    double size = 13,
    Color color = AppColors.purple,
    FontWeight weight = FontWeight.w400,
    double? spacing,
    double height = 1.3,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: spacing,
      height: height,
    );
  }

  static TextStyle display({
    double size = 40,
    Color color = AppColors.purple,
    FontWeight weight = FontWeight.w600,
    double spacing = -1.15,
    double height = 1.14,
  }) {
    return GoogleFonts.cormorantGaramond(
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: spacing,
      height: height,
    );
  }
}
