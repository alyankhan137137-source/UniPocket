import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/budget_model.dart';
import '../models/expense_model.dart';

class BudgetProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBudget => _budgets.where((b) => b.isActive).fold(0.0, (s, b) => s + (b.amount / 100.0));
  double get totalSpent  => _budgets.where((b) => b.isActive).fold(0.0, (s, b) => s + (b.spent  / 100.0));
  double get budgetRemaining => totalBudget - totalSpent;
  double get budgetHealthScore {
    if (totalBudget == 0) return 100;
    final s = 100 - (totalSpent / totalBudget * 100);
    return s < 0 ? 0 : s;
  }

  Future<void> loadBudgets(List<Expense> expenses) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
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
