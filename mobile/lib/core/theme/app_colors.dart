import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============================================
  // LIGHT THEME COLORS
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

  // Background Colors (Light)
  static const Color background = Color(0xFFF8F9FD);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F3F8);

  // Text Colors (Light)
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint = Color(0xFFB2BEC3);
  static const Color textOnPrimary = Colors.white;

  // Status Colors
  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // Other (Light)
  static const Color divider = Color(0xFFE8ECF4);
  static const Color disabled = Color(0xFFDFE6E9);
  static const Color shimmerBase = Color(0xFFE8ECF4);
  static const Color shimmerHighlight = Color(0xFFF8F9FD);
  static const Color card = Colors.white;

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
