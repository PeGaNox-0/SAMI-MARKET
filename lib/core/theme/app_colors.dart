import 'package:flutter/material.dart';

/// Application color palette — professional financial app colors
class AppColors {
  AppColors._();

  // Primary palette — Deep blue (trust, reliability)
  static const Color primary = Color(0xFF1A56DB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E3A8A);

  // Secondary palette
  static const Color secondary = Color(0xFF6366F1);
  static const Color secondaryLight = Color(0xFF818CF8);

  // Semantic colors
  static const Color debt = Color(0xFFDC2626);        // Red — debt
  static const Color debtLight = Color(0xFFFEE2E2);
  static const Color payment = Color(0xFF16A34A);      // Green — payment
  static const Color paymentLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF0EA5E9);

  // Neutral palette
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // Dark mode (Glassmorphism theme)
  static const Color darkBackground = Color(0xFF08080A);   // Deep black canvas
  static const Color darkSurface = Color(0xFF16161A);      // Dark charcoal for glass layers
  static const Color darkSurfaceVariant = Color(0x1AFFFFFF); // Frosted glass surface
  static const Color darkBorder = Color(0x26FFFFFF);       // Glass border
  static const Color darkTextPrimary = Color(0xFFFFFFFF);  // Crisp white
  static const Color darkTextSecondary = Color(0xFFA1A1AA); // Muted silver
}
