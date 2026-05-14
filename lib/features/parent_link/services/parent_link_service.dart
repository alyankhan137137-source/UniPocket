import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parent_link_model.dart';
import '../models/student_snapshot_model.dart';
import '../../../providers/expense_provider.dart';

/// Service responsible for managing the Parent Link lifecycle and data snapshots.
class ParentLinkService {
  static final ParentLinkService _instance = ParentLinkService._internal();
  factory ParentLinkService() => _instance;
  ParentLinkService._internal();

  static const String _storageKey = 'pt_parent_link';

  /// Generates and persists a new parent link.
  Future<ParentLink> generateLink() async {
    final newLink = ParentLink.generate();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(newLink.toMap()));
    return newLink;
  }

  /// Retrieves the active link if it exists and hasn't expired.
  Future<ParentLink?> getActiveLink() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return null;

    final link = ParentLink.fromMap(jsonDecode(raw));
    if (link.isActive && !link.isExpired) {
      return link;
    }
    return null;
  }

  /// Deactivates the current link.
  Future<void> deactivateLink() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      map['isActive'] = 0;
      await prefs.setString(_storageKey, jsonEncode(map));
    }
  }

  /// Builds a student spending snapshot from current application state.
  Future<StudentSnapshot> buildSnapshot(
    ExpenseProvider expenseProvider, 
    String studentName,
  ) async {
    final now = DateTime.now();
    
    // Calculate spending for current month
    final spentThisMonth = expenseProvider.expenses
        .where((e) => e.isExpense && 
                     e.date.month == now.month && 
                     e.date.year == now.year)
        .fold(0.0, (sum, e) => sum + (e.amount / 100.0));

    // Get the last 5 transactions
    final recent = expenseProvider.expenses.take(5).map((e) => {
      'title': e.title,
      'amount': e.amount / 100.0,
      'type': e.type,
      'date': DateFormat('dd MMM').format(e.date),
    }).toList();

    // In a real app, these would come from BudgetProvider, 
    // but we'll use defaults if not specified.
    const double monthlyAllowance = 0.0; 
    final remainingBudget = monthlyAllowance > 0 ? (monthlyAllowance - spentThisMonth) : 0.0;

    return StudentSnapshot(
      studentName: studentName,
      currentBalance: expenseProvider.currentBalance,
      monthlyAllowance: monthlyAllowance,
      spentThisMonth: spentThisMonth,
      remainingBudget: remainingBudget,
      recentTransactions: recent,
      lastUpdated: DateTime.now(),
    );
  }
}
