import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:unipocket/database/database_helper.dart';
import 'package:unipocket/providers/expense_provider.dart';
import 'package:unipocket/features/parent_link/models/parent_link_model.dart';
import 'package:unipocket/features/parent_link/models/student_snapshot_model.dart';

/// Service for managing parent link generation and data snapshot building.
class ParentLinkService {
  static const String _storageKey = 'pt_parent_link_data';

  // Singleton pattern
  ParentLinkService._internal();
  static final ParentLinkService instance = ParentLinkService._internal();

  Future<ParentLink> generateLink() async {
    final link = ParentLink.generate();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(link.toMap()));
    return link;
  }

  Future<ParentLink?> getActiveLink() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return null;

    final link = ParentLink.fromMap(jsonDecode(data) as Map<String, dynamic>);
    
    if (link.isActive && !link.isExpired) {
      return link;
    }
    return null;
  }

  Future<void> deactivateLink() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return;

    final map = jsonDecode(data) as Map<String, dynamic>;
    map['isActive'] = false;
    await prefs.setString(_storageKey, jsonEncode(map));
  }

  Future<StudentSnapshot> buildSnapshot(ExpenseProvider provider, String studentName) async {
    final now = DateTime.now();
    final settings = await DatabaseHelper.instance.getSettings();
    
    final spentThisMonth = provider.expenses
        .where((e) => e.isExpense && e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, e) => sum + (e.amount / 100.0));

    final double monthlyAllowance = settings.monthlyAllowance / 100.0;
    final double remainingBudget = monthlyAllowance - spentThisMonth;

    final recentTransactions = provider.expenses.take(5).map((e) => {
      'title': e.title,
      'amount': e.amount / 100.0,
      'type': e.type,
      'date': DateFormat('dd MMM yyyy').format(e.date),
    }).toList();

    return StudentSnapshot(
      studentName: studentName,
      currentBalance: provider.currentBalance,
      monthlyAllowance: monthlyAllowance,
      spentThisMonth: spentThisMonth,
      remainingBudget: remainingBudget,
      recentTransactions: recentTransactions,
      lastUpdated: now,
    );
  }
}
