import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/expense_model.dart';
import '../models/user_settings_model.dart';
import '../features/recurring/models/recurring_transaction.dart';

/// A centralized helper class for managing application data storage.
/// 
/// This class provides a unified interface for database operations, 
/// abstracting away the platform-specific implementation:
/// - **Mobile (Android/iOS)**: Uses SQLite via the `sqflite` package.
/// - **Web**: Uses `SharedPreferences` to store data as JSON-encoded strings.
/// 
/// It follows the singleton pattern to ensure a single instance is used throughout the app.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  
  /// Factory constructor to return the singleton instance.
  factory DatabaseHelper() => _instance;
  
  DatabaseHelper._internal();
  
  /// Static getter for the singleton instance.
  static DatabaseHelper get instance => _instance;

  // ── SQLite Table Names (mobile only) ──────────────────────────────────────────
  /// Name of the table storing expenses and incomes.
  static const String tableExpenses   = 'expenses';
  
  /// Name of the table storing transaction categories.
  static const String tableCategories = 'categories';
  
  /// Name of the table storing budget configurations.
  static const String tableBudgets    = 'budgets';
  
  /// Name of the table storing user settings.
  static const String tableSettings   = 'settings';
  
  /// Name of the table storing recurring transaction templates.
  static const String tableRecurring  = 'recurring_transactions';

  // ── SharedPreferences Keys (web only) ─────────────────────────────────
  static const String _keyExpenses   = 'pt_expenses';
  static const String _keyBudgets    = 'pt_budgets';
  static const String _keySettings   = 'pt_settings';
  static const String _keyRecurring  = 'pt_recurring';
  static const String _keyNextId     = 'pt_next_id';

  // ─────────────────────────────────────────────────────────────────
  //  Database getter (mobile only)
  // ─────────────────────────────────────────────────────────────────
  static Database? _database;

  /// Returns the underlying SQLite database instance.
  /// 
  /// Throws [UnsupportedError] if called on Web.
  Future<Database> get database async {
    if (kIsWeb) throw UnsupportedError('Use SharedPreferences on Web');
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the SQLite database on mobile platforms.
  Future<Database> _initDatabase() async {
    final dir  = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'pockettrack.db');
    debugPrint('Opening SQLite: $path');
    return await openDatabase(path, version: 5,
        onCreate: _onCreate, onUpgrade: _onUpgrade, onConfigure: _onConfigure);
  }

  // ─────────────────────────────────────────────────────────────────
  //  Web helpers
  // ─────────────────────────────────────────────────────────────────
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Retrieves a list of maps from SharedPreferences for the given [key].
  Future<List<Map<String, dynamic>>> _getList(String key) async {
    final p   = await _prefs;
    final raw = p.getString(key);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  /// Saves a list of maps to SharedPreferences under the given [key].
  Future<void> _saveList(String key, List<Map<String, dynamic>> list) async {
    final p = await _prefs;
    await p.setString(key, jsonEncode(list));
  }

  /// Generates the next sequential ID for web storage.
  Future<int> _nextId() async {
    final p   = await _prefs;
    final id  = (p.getInt(_keyNextId) ?? 0) + 1;
    await p.setInt(_keyNextId, id);
    return id;
  }

  // ─────────────────────────────────────────────────────────────────
  //  Init (seed defaults on first run)
  // ─────────────────────────────────────────────────────────────────
  
  /// Initializes the web storage with default settings if they don't exist.
  Future<void> initWeb() async {
    if (!kIsWeb) return;
    final p = await _prefs;
    if (!p.containsKey(_keySettings)) {
      await p.setString(_keySettings, jsonEncode(UserSettings.defaultSettings().toMap()));
      debugPrint('✅ Default settings seeded');
    }
  }

  /// Placeholder for category verification on web.
  Future<void> ensureCategoriesExist() async {
    // Categories are baked into the UI for web — no DB needed
    debugPrint('✅ Categories OK (web uses built-in list)');
  }

  // ─────────────────────────────────────────────────────────────────
  //  EXPENSES
  // ─────────────────────────────────────────────────────────────────
  
  /// Inserts a new [expense] into the database.
  /// 
  /// Returns the auto-generated ID of the new record.
  Future<int> insertExpense(Expense expense) async {
    if (kIsWeb) {
      final list = await _getList(_keyExpenses);
      final id   = await _nextId();
      final map  = expense.toMap()..['id'] = id;
      list.add(map);
      await _saveList(_keyExpenses, list);
      return id;
    }
    final db = await database;
    return db.insert(tableExpenses, expense.toMap());
  }

  /// Retrieves all non-deleted expenses from the database.
  /// 
  /// Supports [limit] and [offset] for pagination. Results are ordered by date descending.
  Future<List<Expense>> getAllExpenses({int? limit, int? offset}) async {
    if (kIsWeb) {
      final list = await _getList(_keyExpenses);
      final active = list.where((m) => m['is_deleted'] != 1).toList()
        ..sort((a, b) => b['date'].compareTo(a['date']));
      final sliced = (limit != null)
          ? active.skip(offset ?? 0).take(limit).toList()
          : active;
      return sliced.map((m) => Expense.fromMap(m)).toList();
    }
    final db  = await database;
    final res = await db.query('active_expenses',
        orderBy: 'date DESC', limit: limit, offset: offset);
    return res.map((m) => Expense.fromMap(m)).toList();
  }

  /// Marks an expense with the given [id] as deleted (soft delete).
  Future<int> softDeleteExpense(int id) async {
    if (kIsWeb) {
      final list = await _getList(_keyExpenses);
      for (var m in list) {
        if (m['id'] == id) {
          m['is_deleted'] = 1;
          m['deleted_at'] = DateTime.now().toIso8601String();
        }
      }
      await _saveList(_keyExpenses, list);
      return 1;
    }
    final db = await database;
    return db.update(tableExpenses,
        {'is_deleted': 1, 'deleted_at': DateTime.now().toIso8601String()},
        where: 'id = ?', whereArgs: [id]);
  }

  /// Restores a previously soft-deleted expense.
  Future<int> restoreExpense(int id) async {
    if (kIsWeb) {
      final list = await _getList(_keyExpenses);
      for (var m in list) {
        if (m['id'] == id) { m['is_deleted'] = 0; m['deleted_at'] = null; }
      }
      await _saveList(_keyExpenses, list);
      return 1;
    }
    final db = await database;
    return db.update(tableExpenses, {'is_deleted': 0, 'deleted_at': null},
        where: 'id = ?', whereArgs: [id]);
  }

  /// Updates an existing [expense] record.
  Future<int> updateExpense(Expense expense) async {
    if (kIsWeb) {
      final list = await _getList(_keyExpenses);
      for (int i = 0; i < list.length; i++) {
        if (list[i]['id'] == expense.id) { list[i] = expense.toMap()..['id'] = expense.id; }
      }
      await _saveList(_keyExpenses, list);
      return 1;
    }
    final db = await database;
    return db.update(tableExpenses, expense.toMap(),
        where: 'id = ?', whereArgs: [expense.id]);
  }

  // ─────────────────────────────────────────────────────────────────
  //  BUDGETS
  // ─────────────────────────────────────────────────────────────────
  
  /// Retrieves all budget records from the database.
  Future<List<Map<String, dynamic>>> getBudgets() async {
    if (kIsWeb) return _getList(_keyBudgets);
    final db = await database;
    return db.query(tableBudgets);
  }

  /// Inserts a new [budget] record.
  Future<int> insertBudget(Map<String, dynamic> budget) async {
    if (kIsWeb) {
      final list = await _getList(_keyBudgets);
      final id   = await _nextId();
      list.add({...budget, 'id': id});
      await _saveList(_keyBudgets, list);
      return id;
    }
    final db = await database;
    return db.insert(tableBudgets, budget);
  }

  /// Updates an existing [budget] record.
  Future<int> updateBudget(Map<String, dynamic> budget) async {
    if (kIsWeb) {
      final list = await _getList(_keyBudgets);
      for (int i = 0; i < list.length; i++) {
        if (list[i]['id'] == budget['id']) list[i] = budget;
      }
      await _saveList(_keyBudgets, list);
      return 1;
    }
    final db = await database;
    return db.update(tableBudgets, budget,
        where: 'id = ?', whereArgs: [budget['id']]);
  }

  /// Permanently deletes a budget record with the given [id].
  Future<int> deleteBudget(int id) async {
    if (kIsWeb) {
      final list = await _getList(_keyBudgets);
      list.removeWhere((m) => m['id'] == id);
      await _saveList(_keyBudgets, list);
      return 1;
    }
    final db = await database;
    return db.delete(tableBudgets, where: 'id = ?', whereArgs: [id]);
  }

  // ─────────────────────────────────────────────────────────────────
  //  SETTINGS
  // ─────────────────────────────────────────────────────────────────
  
  /// Retrieves the current [UserSettings]. 
  /// 
  /// Returns default settings if none are found in storage.
  Future<UserSettings> getSettings() async {
    if (kIsWeb) {
      final p   = await _prefs;
      final raw = p.getString(_keySettings);
      if (raw == null) return UserSettings.defaultSettings();
      return UserSettings.fromMap(jsonDecode(raw));
    }
    final db   = await database;
    final maps = await db.query(tableSettings, limit: 1);
    if (maps.isEmpty) return UserSettings.defaultSettings();
    return UserSettings.fromMap(maps.first);
  }

  /// Persists the updated [UserSettings].
  Future<void> saveSettings(UserSettings s) async {
    if (kIsWeb) {
      final p = await _prefs;
      await p.setString(_keySettings, jsonEncode(s.toMap()));
      return;
    }
    final db = await database;
    await db.update(tableSettings, s.toMap(),
        where: 'id = ?', whereArgs: [1]);
  }

  // ─────────────────────────────────────────────────────────────────
  //  RECURRING
  // ─────────────────────────────────────────────────────────────────
  
  /// Inserts a new recurring transaction template [r].
  Future<int> insertRecurring(RecurringTransaction r) async {
    if (kIsWeb) {
      final list = await _getList(_keyRecurring);
      list.add(r.toMap());
      await _saveList(_keyRecurring, list);
      return 1;
    }
    final db = await database;
    return db.insert(tableRecurring, r.toMap());
  }

  /// Retrieves all active and non-deleted recurring templates.
  Future<List<RecurringTransaction>> getActiveRecurring() async {
    if (kIsWeb) {
      final list = await _getList(_keyRecurring);
      return list
          .where((m) => m['is_deleted'] != 1 && m['isActive'] == 1)
          .map((m) => RecurringTransaction.fromMap(m))
          .toList();
    }
    final db  = await database;
    final res = await db.query('active_recurring');
    return res.map((m) => RecurringTransaction.fromMap(m)).toList();
  }

  /// Updates an existing recurring transaction template [r].
  Future<int> updateRecurring(RecurringTransaction r) async {
    if (kIsWeb) {
      final list = await _getList(_keyRecurring);
      for (int i = 0; i < list.length; i++) {
        if (list[i]['id'] == r.id) list[i] = r.toMap();
      }
      await _saveList(_keyRecurring, list);
      return 1;
    }
    final db = await database;
    return db.update(tableRecurring, r.toMap(),
        where: 'id = ?', whereArgs: [r.id]);
  }

  // ─────────────────────────────────────────────────────────────────
  //  ANALYTICS helpers
  // ─────────────────────────────────────────────────────────────────
  
  /// Calculates a summary of total income, total expense, and current balance.
  /// 
  /// Values are returned in major currency units (e.g., dollars).
  Future<Map<String, double>> getBalanceSummary() async {
    final expenses = await getAllExpenses();
    double income  = 0, expense = 0;
    for (var e in expenses) {
      if (e.type == 'income') income  += e.amount;
      else                    expense += e.amount;
    }
    return {
      'income':  income  / 100,
      'expense': expense / 100,
      'balance': (income - expense) / 100,
    };
  }

  /// Calculates total spending per category for a specific [month].
  Future<List<Map<String, dynamic>>> getCategoryWiseSpending(DateTime month) async {
    final expenses = await getAllExpenses();
    final Map<String, int> totals = {};
    for (var e in expenses) {
      if (e.type == 'expense' &&
          e.date.year == month.year &&
          e.date.month == month.month) {
        totals[e.category] = (totals[e.category] ?? 0) + e.amount;
      }
    }
    return totals.entries
        .map((e) => {'category': e.key, 'total': e.value})
        .toList()
      ..sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));
  }

  // ─────────────────────────────────────────────────────────────────
  //  CLEAR ALL
  // ─────────────────────────────────────────────────────────────────
  
  /// Deletes all user data from the application, including expenses, budgets,
  /// and recurring templates. Settings are preserved on mobile.
  Future<void> clearAllData() async {
    if (kIsWeb) {
      final p = await _prefs;
      await p.remove(_keyExpenses);
      await p.remove(_keyBudgets);
      await p.remove(_keyRecurring);
      await p.remove(_keyNextId);
      return;
    }
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(tableExpenses);
      await txn.delete(tableBudgets);
      await txn.delete(tableRecurring);
      await txn.delete(tableCategories);
    });
  }

  // ─────────────────────────────────────────────────────────────────
  //  SQLite schema (mobile only)
  // ─────────────────────────────────────────────────────────────────
  
  /// Configures the SQLite database, enabling foreign keys.
  Future _onConfigure(Database db) async {
    if (!kIsWeb) await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Creates the database schema on mobile platforms.
  Future _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS $tableCategories (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, icon TEXT NOT NULL,
      type TEXT NOT NULL, color INTEGER NOT NULL, is_default INTEGER DEFAULT 0,
      is_active INTEGER DEFAULT 1, sort_order INTEGER DEFAULT 0, created_at TEXT NOT NULL)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS $tableExpenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, amount INTEGER NOT NULL,
      category TEXT NOT NULL, date TEXT NOT NULL, type TEXT NOT NULL, note TEXT,
      paymentMethod TEXT, receipt TEXT, createdAt TEXT NOT NULL, updatedAt TEXT NOT NULL,
      is_deleted INTEGER DEFAULT 0, deleted_at TEXT, recurring_id TEXT, category_id TEXT)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS $tableBudgets (
      id INTEGER PRIMARY KEY AUTOINCREMENT, categoryId TEXT NOT NULL, amount INTEGER NOT NULL,
      period TEXT NOT NULL, startDate TEXT NOT NULL, endDate TEXT NOT NULL,
      isActive INTEGER DEFAULT 1, is_deleted INTEGER DEFAULT 0, deleted_at TEXT)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS $tableSettings (
      id INTEGER PRIMARY KEY DEFAULT 1, currency TEXT, theme TEXT, language TEXT,
      budgetAlertPercentage REAL, enableNotifications INTEGER, enableBiometric INTEGER)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS $tableRecurring (
      id TEXT PRIMARY KEY, templateTitle TEXT NOT NULL, amount INTEGER NOT NULL,
      categoryId TEXT NOT NULL, type TEXT NOT NULL, frequency INTEGER NOT NULL,
      interval INTEGER NOT NULL, startDate TEXT NOT NULL, endDate TEXT,
      dayOfMonth INTEGER, dayOfWeek INTEGER, monthOfYear INTEGER,
      lastGeneratedDate TEXT, nextDueDate TEXT NOT NULL, isActive INTEGER DEFAULT 1,
      isPaused INTEGER DEFAULT 0, skipDates TEXT, totalGenerated INTEGER DEFAULT 0,
      note TEXT, createdAt TEXT NOT NULL, is_deleted INTEGER DEFAULT 0, deleted_at TEXT)''');
    
    // Create views for easier querying of active records
    await db.execute('CREATE VIEW IF NOT EXISTS active_expenses AS SELECT * FROM $tableExpenses WHERE is_deleted = 0');
    await db.execute('CREATE VIEW IF NOT EXISTS active_categories AS SELECT * FROM $tableCategories WHERE is_active = 1');
    await db.execute('CREATE VIEW IF NOT EXISTS active_recurring AS SELECT * FROM $tableRecurring WHERE is_deleted = 0 AND isActive = 1');
    
    // Seed default settings
    await db.insert(tableSettings, UserSettings.defaultSettings().toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Handles database migrations.
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {}
}
