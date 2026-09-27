import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application text styles — uses Cairo font for excellent Arabic support
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _baseStyle => GoogleFonts.cairo();

  // Headings
  static TextStyle get headlineLarge => _baseStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get headlineMedium => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get headlineSmall => _baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  // Titles
  static TextStyle get titleLarge => _baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleMedium => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleSmall => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // Body
  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  // Labels
  static TextStyle get labelLarge => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get labelMedium => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get labelSmall => _baseStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  // Special — large monetary amounts
  static TextStyle get moneyLarge => _baseStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get moneyMedium => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get moneySmall => _baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );
}
