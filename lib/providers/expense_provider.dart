import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/expense_model.dart';
import '../utils/widget_helper.dart';
import '../utils/smart_features.dart';
import '../features/parent_link/services/parent_link_service.dart';
import '../features/parent_link/services/cloud_sync_service.dart';

/// A provider that manages the state and business logic for financial transactions.
/// 
/// This class acts as the central hub for handling [Expense] and income records,
/// providing methods for filtering, searching, and calculating financial summaries.
/// It also integrates with [WidgetHelper] to update home screen widgets.
class ExpenseProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTimeRange? _selectedDateRange;
  String? _selectedCategory;
  String _searchQuery = '';

  /// The complete list of transactions fetched from the database.
  List<Expense> get expenses        => _expenses;
  
  /// Whether a database operation is currently in progress.
  bool          get isLoading       => _isLoading;
  
  /// The last error message encountered, if any.
  String?       get errorMessage    => _errorMessage;
  
  /// The active date range filter.
  DateTimeRange? get selectedDateRange => _selectedDateRange;
  
  /// The active category filter.
  String?       get selectedCategory => _selectedCategory;
  
  /// The active text search query.
  String        get searchQuery     => _searchQuery;

  /// Returns the subset of [_expenses] that match the current filters and search query.
  List<Expense> get filteredExpenses => _expenses.where((e) {
    final matchesSearch    = e.title.toLowerCase().contains(_searchQuery.toLowerCase());
    final matchesCategory  = _selectedCategory == null || e.category == _selectedCategory;
    final matchesDate      = _selectedDateRange == null ||
        (!e.date.isBefore(_selectedDateRange!.start) && !e.date.isAfter(_selectedDateRange!.end));
    return matchesSearch && matchesCategory && matchesDate;
  }).toList();

  /// Total income in major currency units.
  double get totalIncome   => _expenses.where((e) => e.isIncome).fold(0.0, (s, e) => s + (e.amount / 100.0));
  
  /// Total expenses in major currency units.
  double get totalExpense  => _expenses.where((e) => e.isExpense).fold(0.0, (s, e) => s + (e.amount / 100.0));
  
  /// Current net balance (Income - Expense).
  double get currentBalance => totalIncome - totalExpense;

  /// Returns the 10 most recent transactions.
  List<Expense> get recentTransactions => _expenses.take(10).toList();

  /// Total amount spent today in major units.
  double get todayExpenses {
    final now = DateTime.now();
    return _expenses.where((e) =>
        e.isExpense && e.date.day == now.day &&
        e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (s, e) => s + (e.amount / 100.0));
  }

  /// Returns a map of category names to their total spending amounts.
  Map<String, double> get categoryWiseExpenses {
    final Map<String, double> data = {};
    for (var e in _expenses.where((e) => e.isExpense)) {
      data[e.category] = (data[e.category] ?? 0.0) + (e.amount / 100.0);
    }
    return data;
  }

  /// Fetches all transactions from the database and updates the UI.
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

  /// Adds a new [expense] or income record and refreshes the list.
  Future<void> addExpense(Expense expense) async {
    try {
      await _dbHelper.insertExpense(expense);
      await fetchExpenses();
      
      try {
        final link = await ParentLinkService.instance.getActiveLink();
        if (link != null) {
          final snapshot = await ParentLinkService.instance.buildSnapshot(this, 'Student');
          await CloudSyncService.instance.syncSnapshot(snapshot, link.accessCode);
        }
      } catch (syncError) {
        debugPrint('Cloud sync after add failed: $syncError');
      }
    } catch (e) {
      _errorMessage = 'Failed to add: $e';
      notifyListeners();
    }
  }

  /// Updates an existing transaction record.
  Future<void> updateExpense(Expense expense) async {
    try {
      await _dbHelper.updateExpense(expense);
      await fetchExpenses();
    } catch (e) {
      _errorMessage = 'Failed to update: $e';
      notifyListeners();
    }
  }

  /// Marks a transaction as deleted (soft delete).
  Future<void> deleteExpense(int id) async {
    try {
      await _dbHelper.softDeleteExpense(id);
      await fetchExpenses();

      try {
        final link = await ParentLinkService.instance.getActiveLink();
        if (link != null) {
          final snapshot = await ParentLinkService.instance.buildSnapshot(this, 'Student');
          await CloudSyncService.instance.syncSnapshot(snapshot, link.accessCode);
        }
      } catch (syncError) {
        debugPrint('Cloud sync after delete failed: $syncError');
      }
    } catch (e) {
      _errorMessage = 'Failed to delete: $e';
      notifyListeners();
    }
  }

  /// Restores a previously soft-deleted transaction.
  Future<void> restoreExpense(int id) async {
    try {
      await _dbHelper.restoreExpense(id);
      await fetchExpenses();
    } catch (e) {
      _errorMessage = 'Failed to restore: $e';
      notifyListeners();
    }
  }

  /// Updates the current search query and triggers a rebuild.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Sets a date range filter for the transaction list.
  void filterByDateRange(DateTime start, DateTime end) {
    _selectedDateRange = DateTimeRange(start: start, end: end);
    notifyListeners();
  }

  /// Generates sample transaction data for testing purposes.
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

  /// Internal method to trigger widget updates (e.g., Home Screen widgets).
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
