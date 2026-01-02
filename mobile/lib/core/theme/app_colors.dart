import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============================================
  // LIGHT THEME COLORS (Refined - Cooler & Softer)
  // ============================================

  // Primary Brand Colors
  static const Color primary = Color(0xFF6C5CE7); // Purple
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF5849C2);

  // Secondary Colors
  static const Color secondary = Color(0xFF00CEC9); // Teal
  static const Color secondaryLight = Color(0xFF81ECEC);

  // Accent Colors
  static const Color accent = Color(0xFFFF7675); // Coral
  static const Color accentYellow = Color(0xFFFDCB6E); // Yellow
  static const Color accentGreen = Color(0xFF00B894); // Green

  // Background Colors (Light) - Refined with cool tones
  static const Color background = Color(0xFFF0F4F8); // Cooler blue-gray
  static const Color surface = Color(0xFFFAFBFC); // Soft off-white
  static const Color surfaceVariant = Color(0xFFE8EDF2); // Cool gray

  // Text Colors (Light) - Softer contrast
  static const Color textPrimary = Color(0xFF1A2530); // Deep blue-gray
  static const Color textSecondary = Color(0xFF5A6978); // Medium blue-gray
  static const Color textHint = Color(0xFF9BA8B4); // Light blue-gray
  static const Color textOnPrimary = Colors.white;

  // Status Colors
  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // Other (Light) - Refined
  static const Color divider = Color(0xFFDDE4EC);
  static const Color disabled = Color(0xFFCED6DE);
  static const Color shimmerBase = Color(0xFFE4EAF0);
  static const Color shimmerHighlight = Color(0xFFF5F8FA);
  static const Color card = Color(0xFFFAFBFC); // Matches surface

  // ============================================
  // DARK THEME COLORS
  // ============================================

  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Text Colors (Dark)
  static const Color textPrimaryDark = Color(0xFFE8E8E8);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textHintDark = Color(0xFF666666);

  // Other (Dark)
  static const Color dividerDark = Color(0xFF333333);
  static const Color disabledDark = Color(0xFF444444);
  static const Color shimmerBaseDark = Color(0xFF2C2C2C);
  static const Color shimmerHighlightDark = Color(0xFF3C3C3C);

  // ============================================
  // GRADIENTS
  // ============================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8E7CF3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [secondary, Color(0xFF55EFC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF7675), Color(0xFFFFAB91)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF2C2C2C), Color(0xFF1E1E1E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // HELPER METHODS
  // ============================================

  static Color getScoreColor(int score) {
    if (score >= 80) return success;
    if (score >= 60) return accentYellow;
    if (score >= 40) return warning;
    return error;
  }

  // Get theme-aware colors
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : background;
  }

  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surface;
  }

  static Color getCard(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? cardDark : card;
  }

  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimaryDark
        : textPrimary;
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecondaryDark
        : textSecondary;
  }

  static Color getDivider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dividerDark
        : divider;
  }
}
