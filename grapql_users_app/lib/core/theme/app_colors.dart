import 'package:flutter/material.dart';

class AppColors {
  // Primary gradient colors
  static const Color blue600 = Color(0xFF2563EB);
  static const Color purple600 = Color(0xFF9333EA);
  static const Color pink600 = Color(0xFFDB2777);

  // Background colors
  static const Color backgroundLight = Color(0xFFF5F5F9);
  static const Color white = Colors.white;

  // Text colors
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textWhite = Colors.white;

  // Status colors
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;

  // Border colors
  static const Color borderFocus = purple600;
  static const Color borderError = error;

  // Gradient
  static const List<Color> primaryGradient = [
    blue600,
    purple600,
    pink600,
  ];

  // Shimmer colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
