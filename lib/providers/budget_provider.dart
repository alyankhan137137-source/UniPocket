import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/budget_model.dart';
import '../models/expense_model.dart';

/// A provider that manages the state and business logic for category-based budgets.
/// 
/// This class handles loading budgets from the database, calculating spending progress
/// against those budgets using current transaction data, and providing CRUD operations.
class BudgetProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;

  /// The list of budgets currently loaded in memory, with calculated spending.
  List<Budget> get budgets => _budgets;
  
  /// Whether the provider is currently fetching or processing budget data.
  bool get isLoading => _isLoading;
  
  /// Contains a descriptive message if the last operation failed.
  String? get error => _error;

  /// Returns the sum of all active budget limits in major currency units.
  double get totalBudget => _budgets.where((b) => b.isActive).fold(0.0, (s, b) => s + (b.amount / 100.0));
  
  /// Returns the sum of all spending against active budgets in major units.
  double get totalSpent  => _budgets.where((b) => b.isActive).fold(0.0, (s, b) => s + (b.spent  / 100.0));
  
  /// The difference between the total budget and total spending.
  double get budgetRemaining => totalBudget - totalSpent;
  
  /// A percentage score (0-100) representing overall budget utilization.
  /// 100 means no spending, 0 means total budget is consumed or exceeded.
  double get budgetHealthScore {
    if (totalBudget == 0) return 100;
    final s = 100 - (totalSpent / totalBudget * 100);
    return s < 0 ? 0 : s;
  }

  /// Fetches budgets from the database and calculates current spending for each.
  /// 
  /// [expenses] is the list of current transactions used to calculate `spent` amounts.
  Future<void> loadBudgets(List<Expense> expenses) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final maps = await _db.getBudgets();
      _budgets = maps.map((m) {
        final b = Budget.fromMap(m);
        // Calculate spending for this specific budget category and period
        final spent = expenses.where((e) =>
          e.isExpense && e.category == b.categoryId &&
          !e.date.isBefore(b.startDate) && !e.date.isAfter(b.endDate)
        ).fold(0, (s, e) => s + e.amount);
        return b.copyWith(spent: spent);
      }).toList();
    } catch (e) { _error = 'Failed to load budgets: $e'; }
    finally { _isLoading = false; notifyListeners(); }
  }

  /// Adds a new budget to the database and refreshes the local state.
  Future<void> addBudget(Budget b, List<Expense> expenses) async {
    try { await _db.insertBudget(b.toMap()); await loadBudgets(expenses); }
    catch (e) { _error = 'Failed to add: $e'; notifyListeners(); }
  }

  /// Updates an existing budget and refreshes the local state.
  Future<void> updateBudget(Budget b, List<Expense> expenses) async {
    try { await _db.updateBudget(b.toMap()); await loadBudgets(expenses); }
    catch (e) { _error = 'Failed to update: $e'; notifyListeners(); }
  }

  /// Deletes a budget by its unique [id] and refreshes the local state.
  Future<void> deleteBudget(int id, List<Expense> expenses) async {
    try { await _db.deleteBudget(id); await loadBudgets(expenses); }
    catch (e) { _error = 'Failed to delete: $e'; notifyListeners(); }
  }

  /// Returns the utilization ratio (spent / limit) for a specific category.
  double getBudgetStatus(String categoryId) {
    final b = _budgets.where((b) => b.categoryId == categoryId).firstOrNull;
    if (b == null || b.amount == 0) return 0;
    return b.spent / b.amount.toDouble();
  }

  /// Returns a list of budgets where the spending has exceeded the limit.
  List<Budget> getOverspentCategories() => _budgets.where((b) => b.isExceeded).toList();
}
