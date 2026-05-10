import 'package:flutter/material.dart';

/// Application-wide constants for categories, formats, and animations.
/// 
/// This class stores configuration values that remain constant across
/// the entire app lifecycle, such as default categories, date formats,
/// and animation durations.
class AppConstants {
  AppConstants._();

  // --- Currency & Formats ---
  /// The default currency symbol displayed next to monetary values.
  static const String currencySymbol = '\$';
  
  /// The ISO currency code used for formatting and API interactions.
  static const String currencyCode = 'USD';
  
  /// The standard pattern used for formatting dates in the UI.
  static const String dateFormat = 'dd MMM yyyy';
  
  /// The standard pattern used for formatting times in the UI.
  static const String timeFormat = 'hh:mm a';

  // --- Animation Durations ---
  /// Fast animation duration for small transitions like fades.
  static const Duration durationShort = Duration(milliseconds: 200);
  
  /// Standard animation duration for page transitions or UI shifts.
  static const Duration durationMedium = Duration(milliseconds: 400);
  
  /// Slow animation duration for more complex or dramatic transitions.
  static const Duration durationLong = Duration(milliseconds: 600);

  // --- Default Categories: Expense ---
  /// Initial list of categories for expenses, used to seed the database.
  static const List<Map<String, dynamic>> expenseCategories = [
    {'name': 'Food', 'emoji': '🍔', 'color': Color(0xFFFF7043)},
    {'name': 'Transport', 'emoji': '🚗', 'color': Color(0xFF42A5F5)},
    {'name': 'Groceries', 'emoji': '🛒', 'color': Color(0xFF66BB6A)},
    {'name': 'Entertainment', 'emoji': '🎬', 'color': Color(0xFFAB47BC)},
    {'name': 'Health', 'emoji': '💊', 'color': Color(0xFF26A69A)},
    {'name': 'Shopping', 'emoji': '🛍️', 'color': Color(0xFFFFA726)},
    {'name': 'Utilities', 'emoji': '💡', 'color': Color(0xFF78909C)},
    {'name': 'Personal', 'emoji': '👕', 'color': Color(0xFFEC407A)},
    {'name': 'Education', 'emoji': '📚', 'color': Color(0xFF5C6BC0)},
    {'name': 'Gifts', 'emoji': '🎁', 'color': Color(0xFFFFCA28)},
    {'name': 'Other', 'emoji': '📦', 'color': Color(0xFF9E9E9E)},
  ];

  // --- Default Categories: Income ---
  /// Initial list of categories for income, used to seed the database.
  static const List<Map<String, dynamic>> incomeCategories = [
    {'name': 'Salary', 'emoji': '💰', 'color': Color(0xFF4CAF50)},
    {'name': 'Freelance', 'emoji': '💻', 'color': Color(0xFF81C784)},
    {'name': 'Investment', 'emoji': '📈', 'color': Color(0xFF388E3C)},
    {'name': 'Refund', 'emoji': '🔙', 'color': Color(0xFF66BB6A)},
    {'name': 'Other', 'emoji': '💵', 'color': Color(0xFFA5D6A7)},
  ];

  // --- Chart Colors ---
  /// A curated list of colors used to differentiate segments in charts and graphs.
  static const List<Color> chartColors = [
    Color(0xFF6C63FF),
    Color(0xFF03DAC6),
    Color(0xFFFF7043),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFAB47BC),
    Color(0xFFFFA726),
    Color(0xFFEC407A),
  ];
}
