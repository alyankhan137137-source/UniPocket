import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/expense_model.dart';
import '../utils/widget_helper.dart';
import '../utils/smart_features.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTimeRange? _selectedDateRange;
  String? _selectedCategory;
  String _searchQuery = '';

  List<Expense> get expenses        => _expenses;
  bool          get isLoading       => _isLoading;
  String?       get errorMessage    => _errorMessage;
  DateTimeRange? get selectedDateRange => _selectedDateRange;
  String?       get selectedCategory => _selectedCategory;
  String        get searchQuery     => _searchQuery;

  List<Expense> get filteredExpenses => _expenses.where((e) {
    final matchesSearch    = e.title.toLowerCase().contains(_searchQuery.toLowerCase());
    final matchesCategory  = _selectedCategory == null || e.category == _selectedCategory;
    final matchesDate      = _selectedDateRange == null ||
        (!e.date.isBefore(_selectedDateRange!.start) && !e.date.isAfter(_selectedDateRange!.end));
    return matchesSearch && matchesCategory && matchesDate;
  }).toList();

  double get totalIncome   => _expenses.where((e) => e.isIncome).fold(0.0, (s, e) => s + (e.amount / 100.0));
  double get totalExpense  => _expenses.where((e) => e.isExpense).fold(0.0, (s, e) => s + (e.amount / 100.0));
  double get currentBalance => totalIncome - totalExpense;

  List<Expense> get recentTransactions => _expenses.take(10).toList();

  double get todayExpenses {
    final now = DateTime.now();
    return _expenses.where((e) =>
        e.isExpense && e.date.day == now.day &&
        e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (s, e) => s + (e.amount / 100.0));
  }

  Map<String, double> get categoryWiseExpenses {
    final Map<String, double> data = {};
    for (var e in _expenses.where((e) => e.isExpense)) {
      data[e.category] = (data[e.category] ?? 0.0) + (e.amount / 100.0);
    }
    return data;
  }

  Future<void> fetchExpenses() async {
    _setLoading(true);
    try {
      _expenses = await _dbHelper.getAllExpenses();
      _errorMessage = null;
      _updateWidgets();
    } catch (e) {
      _errorMessage = 'Failed to load: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _dbHelper.insertExpense(expense);
      await fetchExpenses();
    } catch (e) {
      _errorMessage = 'Failed to add: $e';
      notifyListeners();
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _dbHelper.updateExpense(expense);
      await fetchExpenses();
    } catch (e) {
      _errorMessage = 'Failed to update: $e';
      notifyListeners();
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _dbHelper.softDeleteExpense(id);
      await fetchExpenses();
    } catch (e) {
      _errorMessage = 'Failed to delete: $e';
      notifyListeners();
    }
  }

  Future<void> restoreExpense(int id) async {
    try {
      await _dbHelper.restoreExpense(id);
      await fetchExpenses();
    } catch (e) {
      _errorMessage = 'Failed to restore: $e';
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void filterByDateRange(DateTime start, DateTime end) {
    _selectedDateRange = DateTimeRange(start: start, end: end);
    notifyListeners();
  }

  // ✅ Demo data generation — inside the class
  Future<void> generateDemoData() async {
    try {
      final demos = SmartFeatures.generateDemoExpenses();
      for (final d in demos) {
        final expense = Expense(
          title:         d['title'] as String,
          amount:        d['amount'] as int,
          category:      d['category'] as String,
          date:          d['date'] as DateTime,
          type:          d['type'] as String,
          paymentMethod: d['paymentMethod'] as String,
          note:          'Demo data',
          createdAt:     DateTime.now(),
          updatedAt:     DateTime.now(),
        );
        await _dbHelper.insertExpense(expense);
      }
      await SmartFeatures.markDemoDataGenerated();
      await fetchExpenses();
    } catch (e) {
      _errorMessage = 'Failed to generate demo data: $e';
      notifyListeners();
    }
  }

  void _updateWidgets() {
    WidgetHelper.updateBalanceWidget(
      balance: currentBalance,
      income:  totalIncome,
      expense: totalExpense,
    );
    WidgetHelper.updateRecentTransactionsWidget(recentTransactions);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
