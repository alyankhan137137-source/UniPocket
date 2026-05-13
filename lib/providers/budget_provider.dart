import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/budget_model.dart';
import '../models/expense_model.dart';

/// A provider that manages the state and business logic for category-based budgets.
class BudgetProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;
  double _totalMonthlySpent = 0;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Returns the sum of all active category budget limits in major currency units.
  double get totalBudget => _budgets.where((b) => b.isActive).fold(0.0, (s, b) => s + (b.amount / 100.0));
  
  /// Returns the sum of all spending against active budgets in major units.
  double get totalSpent  => _budgets.where((b) => b.isActive).fold(0.0, (s, b) => s + (b.spent  / 100.0));
  
  /// Total expenses for the current month across all categories.
  double get totalMonthlySpent => _totalMonthlySpent;

  double get budgetRemaining => totalBudget - totalSpent;
  
  double get budgetHealthScore {
    if (totalBudget == 0) return 100;
    final s = 100 - (totalSpent / totalBudget * 100);
    return s < 0 ? 0 : s;
  }

  Future<void> loadBudgets(List<Expense> expenses) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final now = DateTime.now();

      // Calculate total monthly spending (all categories)
      _totalMonthlySpent = expenses.where((e) =>
        e.isExpense && e.date.year == now.year && e.date.month == now.month
      ).fold(0.0, (sum, e) => sum + (e.amount / 100.0));

      final maps = await _db.getBudgets();
      _budgets = maps.map((m) {
        final b = Budget.fromMap(m);
        final spent = expenses.where((e) =>
          e.isExpense && e.category == b.categoryId &&
          !e.date.isBefore(b.startDate) && !e.date.isAfter(b.endDate)
        ).fold(0, (s, e) => s + e.amount);
        return b.copyWith(spent: spent);
      }).toList();
    } catch (e) { _error = 'Failed to load budgets: $e'; }
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> addBudget(Budget b, List<Expense> expenses) async {
    try { await _db.insertBudget(b.toMap()); await loadBudgets(expenses); }
    catch (e) { _error = 'Failed to add: $e'; notifyListeners(); }
  }

  Future<void> updateBudget(Budget b, List<Expense> expenses) async {
    try { await _db.updateBudget(b.toMap()); await loadBudgets(expenses); }
    catch (e) { _error = 'Failed to update: $e'; notifyListeners(); }
  }

  Future<void> deleteBudget(int id, List<Expense> expenses) async {
    try { await _db.deleteBudget(id); await loadBudgets(expenses); }
    catch (e) { _error = 'Failed to delete: $e'; notifyListeners(); }
  }

  double getBudgetStatus(String categoryId) {
    final b = _budgets.where((b) => b.categoryId == categoryId).firstOrNull;
    if (b == null || b.amount == 0) return 0;
    return b.spent / b.amount.toDouble();
  }

  List<Budget> getOverspentCategories() => _budgets.where((b) => b.isExceeded).toList();
}
