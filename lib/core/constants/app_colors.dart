import 'package:flutter/material.dart';

/// App-wide color palette tailored for the EcoTrack environmental theme
class AppColors {
  AppColors._();

  // Primary Brand Colors (Eco Greens)
  static const Color primary = Color(0xFF2E7D32); // Forest Green
  static const Color primaryLight = Color(0xFF4CAF50); // Vibrant Leaf Green
  static const Color primaryDark = Color(0xFF1B5E20); // Deep Forest Green

  // Secondary & Accent Colors
  static const Color secondary = Color(0xFF00897B); // Teal Green
  static const Color accent = Color(0xFF8BC34A); // Light Green / Lime
  static const Color energy = Color(0xFFFFB300); // Solar Amber / Points
  static const Color earth = Color(0xFF8D6E63); // Earth Brown
  static const Color waste = Color(0xFF8D6E63); // Recycling / Waste
  static const Color water = Color(0xFF0288D1); // Water Blue
  static const Color transport = Color(0xFF00897B); // Clean Transport

  // Background & Surface Colors (Light)
  static const Color backgroundLight = Color(0xFFF7FAF7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Background & Surface Colors (Dark)
  static const Color backgroundDark = Color(0xFF121B13);
  static const Color surfaceDark = Color(0xFF1E2820);
  static const Color cardDark = Color(0xFF243326);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1C2D1F);
  static const Color textSecondaryLight = Color(0xFF6B7D6E);
  static const Color textPrimaryDark = Color(0xFFE8F5E9);
  static const Color textSecondaryDark = Color(0xFF9EABA0);

  // Status & Feedback Colors
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);

  // Neutral Grays & Dividers
  static const Color borderLight = Color(0xFFE0E7E1);
  static const Color borderDark = Color(0xFF2E3E31);
  static const Color dividerLight = Color(0xFFECEFEA);
  static const Color dividerDark = Color(0xFF2B3A2D);
}
