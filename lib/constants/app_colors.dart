import 'package:flutter/material.dart';

/// A professional color scheme for the PocketTrack Lite app.
/// Includes primary gradients, status colors, and category-specific palettes.
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // --- Primary Colors ---
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52D5);
  static const Color secondary = Color(0xFF03DAC6);

  // --- Status Colors ---
  static const Color income = Color(0xFF4CAF50); // Modern Green
  static const Color expense = Color(0xFFE53935); // Modern Red
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFBC02D);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);

  // --- Light Theme Colors ---
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF9196A2);
  static const Color textHint = Color(0xFFBCC1CD);

  // --- Dark Theme Colors ---
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardBackgroundDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFE1E1E1);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  static const Color textHintDark = Color(0xFF666666);

  // --- Text Colors (On Primary) ---
  static const Color textOnPrimary = Colors.white;

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF8A84FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFEF5350)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Category Specific Colors ---
  static const List<Color> categoryColors = [
    Color(0xFFFF7043), // Food
    Color(0xFF42A5F5), // Transport
    Color(0xFF66BB6A), // Groceries
    Color(0xFFAB47BC), // Entertainment
    Color(0xFF26A69A), // Health
    Color(0xFFFFA726), // Shopping
    Color(0xFF78909C), // Utilities
    Color(0xFFEC407A), // Personal
    Color(0xFF5C6BC0), // Education
    Color(0xFFFFCA28), // Gifts
  ];

  // --- Shadows ---
  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.2),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}
