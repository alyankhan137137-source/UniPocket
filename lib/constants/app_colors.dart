import 'package:flutter/material.dart';

/// A professional color scheme for the UniPocket app.
/// 
/// This class centralizes all color definitions used across the application,
/// including primary gradients, status colors, and category-specific palettes.
/// Using this centralized approach ensures a consistent look and feel.
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // --- Primary Colors ---
  /// The main brand color used for primary buttons, highlights, and key UI elements.
  static const Color primary = Color(0xFF6C63FF);
  
  /// A darker shade of the primary color for pressed states or accents.
  static const Color primaryDark = Color(0xFF5A52D5);
  
  /// The accent color used for secondary actions or contrasting elements.
  static const Color secondary = Color(0xFF03DAC6);

  // --- Status Colors ---
  /// Color representing positive financial transactions or allowance.
  static const Color income = Color(0xFF4CAF50); // Modern Green
  
  /// Color representing negative financial transactions or expenses.
  static const Color expense = Color(0xFFE53935); // Modern Red
  
  /// Color used for success messages and indicators.
  static const Color success = Color(0xFF388E3C);
  
  /// Color used for warning alerts or cautionary states.
  static const Color warning = Color(0xFFFBC02D);
  
  /// Color used for critical errors and destructive actions.
  static const Color error = Color(0xFFD32F2F);
  
  /// Color used for informational prompts and tooltips.
  static const Color info = Color(0xFF1976D2);

  // --- Light Theme Colors ---
  /// Default background color for the application in light mode.
  static const Color background = Color(0xFFF8F9FE);
  
  /// Surface color for components like cards and dialogs in light mode.
  static const Color surface = Colors.white;
  
  /// Specific background color for cards in light mode.
  static const Color cardBackground = Colors.white;
  
  /// Primary text color for high-emphasis content in light mode.
  static const Color textPrimary = Color(0xFF2D3142);
  
  /// Secondary text color for medium-emphasis content in light mode.
  static const Color textSecondary = Color(0xFF9196A2);
  
  /// Hint text color for placeholders and disabled states in light mode.
  static const Color textHint = Color(0xFFBCC1CD);

  // --- Dark Theme Colors ---
  /// Default background color for the application in dark mode.
  static const Color backgroundDark = Color(0xFF121212);
  
  /// Surface color for components like cards and dialogs in dark mode.
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  /// Specific background color for cards in dark mode.
  static const Color cardBackgroundDark = Color(0xFF1E1E1E);
  
  /// Primary text color for high-emphasis content in dark mode.
  static const Color textPrimaryDark = Color(0xFFE1E1E1);
  
  /// Secondary text color for medium-emphasis content in dark mode.
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  
  /// Hint text color for placeholders and disabled states in dark mode.
  static const Color textHintDark = Color(0xFF666666);

  // --- Text Colors (On Primary) ---
  /// Text color used on top of the primary color to ensure readability.
  static const Color textOnPrimary = Colors.white;

  // --- Gradients ---
  /// Standard brand gradient used for headers and primary cards.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF8A84FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient specifically for allowance-related visual elements.
  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient specifically for expense-related visual elements.
  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFEF5350)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Category Specific Colors ---
  /// A collection of colors used to visually distinguish different transaction categories.
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
  /// Standard shadow applied to primary interactive elements.
  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.2),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  /// Subtle shadow for cards and containers in light mode.
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  /// Defined shadow for cards and containers in dark mode.
  static List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}
