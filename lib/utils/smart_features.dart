import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_model.dart';

/// Handles all smart UX features:
/// - Remember last used category
/// - Duplicate detection
/// - Smart suggestions based on title
/// - Demo data generation
/// - Search history
/// - Haptic feedback
class SmartFeatures {
  static const _lastCategoryKey = 'last_used_category_';
  static const _searchHistoryKey = 'search_history';
  static const _demoDataKey = 'demo_data_generated';

  // ── Haptic Feedback ──────────────────────────────────────────────
  static void lightTap() {
    HapticFeedback.lightImpact();
  }

  static void mediumTap() {
    HapticFeedback.mediumImpact();
  }

  static void successVibrate() {
    HapticFeedback.selectionClick();
  }

  static void errorVibrate() {
    HapticFeedback.vibrate();
  }

  // ── Remember Last Used Category ──────────────────────────────────
  static Future<String?> getLastCategory(String type) async {
    final p = await SharedPreferences.getInstance();
    return p.getString('$_lastCategoryKey$type');
  }

  static Future<void> saveLastCategory(String type, String category) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('$_lastCategoryKey$type', category);
  }

  // ── Smart Title Suggestions ──────────────────────────────────────
  // Auto-suggest category based on title keywords
  static String? suggestCategory(String title, String type) {
    final t = title.toLowerCase();
    if (type == 'expense') {
      if (_matches(t, ['coffee', 'tea', 'restaurant', 'food', 'lunch', 'dinner', 'breakfast', 'cafe', 'eat', 'pizza', 'burger']))
        return 'Food & Dining';
      if (_matches(t, ['uber', 'taxi', 'bus', 'metro', 'fuel', 'petrol', 'gas', 'car', 'ride', 'transport']))
        return 'Transport';
      if (_matches(t, ['amazon', 'shop', 'buy', 'purchase', 'mall', 'store', 'cloth', 'shoe', 'dress']))
        return 'Shopping';
      if (_matches(t, ['electricity', 'water', 'internet', 'wifi', 'bill', 'utility', 'phone', 'subscription']))
        return 'Bills & Utilities';
      if (_matches(t, ['doctor', 'hospital', 'medicine', 'pharmacy', 'health', 'clinic', 'dental', 'gym']))
        return 'Health';
      if (_matches(t, ['netflix', 'movie', 'game', 'spotify', 'entertainment', 'cinema', 'concert']))
        return 'Entertainment';
      if (_matches(t, ['school', 'course', 'book', 'tuition', 'university', 'education', 'class', 'learn']))
        return 'Education';
      if (_matches(t, ['rent', 'house', 'apartment', 'landlord', 'maintenance', 'home']))
        return 'Rent';
      if (_matches(t, ['grocery', 'vegetable', 'fruit', 'market', 'supermarket', 'carrefour', 'lulu']))
        return 'Groceries';
    } else {
      if (_matches(t, ['salary', 'pay', 'wage', 'payroll', 'stipend'])) return 'Salary';
      if (_matches(t, ['freelance', 'client', 'project', 'contract', 'gig'])) return 'Freelance';
      if (_matches(t, ['business', 'profit', 'revenue', 'sale', 'income'])) return 'Business';
      if (_matches(t, ['invest', 'dividend', 'stock', 'crypto', 'return', 'interest'])) return 'Investment';
      if (_matches(t, ['gift', 'bonus', 'reward', 'cashback', 'refund'])) return 'Gift';
    }
    return null;
  }

  static bool _matches(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  // ── Duplicate Detection ──────────────────────────────────────────
  static Expense? findDuplicate(List<Expense> expenses, {
    required String title,
    required int amountCents,
    required String type,
    required DateTime date,
  }) {
    return expenses.where((e) {
      final sameTitle  = e.title.toLowerCase() == title.toLowerCase();
      final sameAmount = e.amount == amountCents;
      final sameType   = e.type == type;
      final dayDiff    = e.date.difference(date).inDays.abs();
      return sameTitle && sameAmount && sameType && dayDiff <= 1;
    }).firstOrNull;
  }

  // ── Search History ───────────────────────────────────────────────
  static Future<List<String>> getSearchHistory() async {
    final p = await SharedPreferences.getInstance();
    return p.getStringList(_searchHistoryKey) ?? [];
  }

  static Future<void> addToSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    final p = await SharedPreferences.getInstance();
    final history = p.getStringList(_searchHistoryKey) ?? [];
    history.remove(query); // remove duplicate
    history.insert(0, query);
    // Keep only last 10
    await p.setStringList(_searchHistoryKey, history.take(10).toList());
  }

  static Future<void> clearSearchHistory() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_searchHistoryKey);
  }

  // ── Demo Data Generation ─────────────────────────────────────────
  static Future<bool> isDemoDataGenerated() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_demoDataKey) ?? false;
  }

  static Future<void> markDemoDataGenerated() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_demoDataKey, true);
  }

  static List<Map<String, dynamic>> generateDemoExpenses() {
    final now = DateTime.now();
    return [
      {'title': 'Monthly Salary', 'amount': 500000, 'category': 'Salary', 'type': 'income', 'date': now.subtract(const Duration(days: 20)), 'paymentMethod': 'Bank'},
      {'title': 'Freelance Project', 'amount': 150000, 'category': 'Freelance', 'type': 'income', 'date': now.subtract(const Duration(days: 15)), 'paymentMethod': 'Bank'},
      {'title': 'Grocery Shopping', 'amount': 8500, 'category': 'Groceries', 'type': 'expense', 'date': now.subtract(const Duration(days: 1)), 'paymentMethod': 'Card'},
      {'title': 'Coffee at Starbucks', 'amount': 2500, 'category': 'Food & Dining', 'type': 'expense', 'date': now.subtract(const Duration(days: 2)), 'paymentMethod': 'Cash'},
      {'title': 'Uber Ride', 'amount': 1800, 'category': 'Transport', 'type': 'expense', 'date': now.subtract(const Duration(days: 3)), 'paymentMethod': 'Card'},
      {'title': 'Netflix Subscription', 'amount': 4500, 'category': 'Entertainment', 'type': 'expense', 'date': now.subtract(const Duration(days: 5)), 'paymentMethod': 'Card'},
      {'title': 'Electricity Bill', 'amount': 12000, 'category': 'Bills & Utilities', 'type': 'expense', 'date': now.subtract(const Duration(days: 7)), 'paymentMethod': 'Bank'},
      {'title': 'Restaurant Dinner', 'amount': 6500, 'category': 'Food & Dining', 'type': 'expense', 'date': now.subtract(const Duration(days: 8)), 'paymentMethod': 'Cash'},
      {'title': 'Online Course', 'amount': 9900, 'category': 'Education', 'type': 'expense', 'date': now.subtract(const Duration(days: 10)), 'paymentMethod': 'Card'},
      {'title': 'Gym Membership', 'amount': 7500, 'category': 'Health', 'type': 'expense', 'date': now.subtract(const Duration(days: 12)), 'paymentMethod': 'Card'},
    ];
  }
}
