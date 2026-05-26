import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/expense_model.dart';
import '../models/budget_model.dart';
import '../models/user_settings_model.dart';
import '../features/recurring/models/recurring_transaction.dart';

class DatabaseHelper {
  // Private constructor
  DatabaseHelper._internal();

  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Static getter for the singleton instance
  static DatabaseHelper get instance => _instance;

  // Factory constructor to return the singleton instance
  factory DatabaseHelper() {
    return _instance;
  }

  static Database? _database;

  static const String tableExpenses = 'expenses';
  static const String tableBudgets = 'budgets';
  static const String tableSettings = 'settings';
  static const String tableRecurring = 'recurring_transactions';
  static const String tableCategories = 'categories';

  static const String _keyExpenses = 'expenses_data';
  static const String _keyBudgets = 'budgets_data';
  static const String _keyRecurring = 'recurring_data';
  static const String _keyNextId = 'next_id';

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('Use SharedPreferences on Web');
    }
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('unipocket.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Using dart:io professionally: Ensure the database directory exists
    final directory = Directory(dbPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return await openDatabase(
      path,
      version: 8,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Professional utility using dart:io to check the health/size of the database.
  Future<int> getDatabaseSize() async {
    if (kIsWeb) return 0;
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'unipocket.db');
      final file = File(path);
      return await file.exists() ? await file.length() : 0;
    } catch (e) {
      debugPrint('Error getting database size: $e');
      return 0;
    }
  }

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<List<Map<String, dynamic>>> _getList(String key) async {
    final p = await _prefs;
    final data = p.getString(key);
    if (data == null) {
      return [];
    }
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  Future<void> _saveList(String key, List<Map<String, dynamic>> list) async {
    final p = await _prefs;
    await p.setString(key, jsonEncode(list));
  }

  Future<void> initWeb() async {
    if (!kIsWeb) {
      return;
    }
    final p = await _prefs;
    if (p.getString('categories_data') == null) {
      await ensureCategoriesExist();
    }
  }

  // Categories
  Future<void> ensureCategoriesExist() async {
    final categories = ['Rent', 'Groceries', 'Eating Out', 'Transport', 'Tuition & Fees', 'Textbooks', 'Subscriptions', 'Going Out', 'Health', 'Clothing', 'Tech', 'Other'];
    if (kIsWeb) {
      final p = await _prefs;
      if (p.getString('categories_data') != null) {
        return;
      }
      final list = categories.map((name) => {
        'id': name.toLowerCase().replaceAll(' ', '_').replaceAll('&', '').replaceAll('__', '_'),
        'name': name,
        'icon': _getIconForCategory(name),
        'type': 'expense',
        'color': _getColorForCategory(name),
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String()
      }).toList();
      await p.setString('categories_data', jsonEncode(list));
      return;
    }
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableCategories'));
    if (count == 0) {
      for (var name in categories) {
        await db.insert(tableCategories, {
          'id': name.toLowerCase().replaceAll(' ', '_').replaceAll('&', '').replaceAll('__', '_'),
          'name': name,
          'icon': _getIconForCategory(name),
          'type': 'expense',
          'color': _getColorForCategory(name),
          'is_default': 1,
          'created_at': DateTime.now().toIso8601String()
        });
      }
    }
  }

  String _getIconForCategory(String name) {
    switch (name) {
      case 'Rent': return 'home';
      case 'Groceries': return 'shopping_cart';
      case 'Eating Out': return 'restaurant';
      case 'Transport': return 'directions_bus';
      case 'Tuition & Fees': return 'school';
      case 'Textbooks': return 'book';
      case 'Subscriptions': return 'subscriptions';
      case 'Going Out': return 'local_bar';
      case 'Health': return 'medical_services';
      case 'Clothing': return 'checkroom';
      case 'Tech': return 'laptop';
      default: return 'category';
    }
  }

  int _getColorForCategory(String name) {
    switch (name) {
      case 'Rent': return 0xFFE57373;
      case 'Groceries': return 0xFF81C784;
      case 'Eating Out': return 0xFFFFB74D;
      case 'Transport': return 0xFF64B5F6;
      case 'Tuition & Fees': return 0xFF9575CD;
      case 'Textbooks': return 0xFF4DB6AC;
      case 'Subscriptions': return 0xFFF06292;
      case 'Going Out': return 0xFFFF8A65;
      case 'Health': return 0xFF4FC3F7;
      case 'Clothing': return 0xFFAED581;
      case 'Tech': return 0xFF7986CB;
      default: return 0xFF90A4AE;
    }
  }

  // Expenses
  Future<int> insertExpense(Expense expense) async {
    if (kIsWeb) {
      final list = await _getList(_keyExpenses);
      final p = await _prefs;
      final id = (p.getInt(_keyNextId) ?? 0) + 1;
      final eMap = expense.toMap();
      eMap['id'] = id;
      list.insert(0, eMap);
      await _saveList(_keyExpenses, list);
      await p.setInt(_keyNextId, id);
      return id;
    }
    final db = await database;
    return await db.insert(tableExpenses, expense.toMap());
  }

  Future<List<Expense>> getAllExpenses({int? limit, int? offset}) async {
    if (kIsWeb) {
      var list = await _getList(_keyExpenses);
      var filtered = list.where((m) => m['is_deleted'] != 1).map((m) => Expense.fromMap(m)).toList();
      if (offset != null) {
        if (offset < filtered.length) {
          filtered = filtered.sublist(offset);
        }
      }
      if (limit != null) {
        if (limit < filtered.length) {
          filtered = filtered.sublist(0, limit);
        }
      }
      return filtered;
    }
    final db = await database;
    final res = await db.query(
      'active_expenses',
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );
    return res.map((m) => Expense.fromMap(m)).toList();
  }

  Future<int> updateExpense(Expense expense) async {
    if (kIsWeb) {
      final list = await _getList(_keyExpenses);
      final idx = list.indexWhere((m) => m['id'] == expense.id);
      if (idx != -1) {
        list[idx] = expense.toMap();
        await _saveList(_keyExpenses, list);
        return 1;
      }
      return 0;
    }
    final db = await database;
    return await db.update(tableExpenses, expense.toMap(), where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<int> softDeleteExpense(int id) async {
    if (kIsWeb) {
      final list = await _getList(_keyExpenses);
      final idx = list.indexWhere((m) => m['id'] == id);
      if (idx != -1) {
        list[idx]['is_deleted'] = 1;
        list[idx]['deleted_at'] = DateTime.now().toIso8601String();
        await _saveList(_keyExpenses, list);
        return 1;
      }
      return 0;
    }
    final db = await database;
    return await db.update(tableExpenses, {
      'is_deleted': 1,
      'deleted_at': DateTime.now().toIso8601String()
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> restoreExpense(int id) async {
    if (kIsWeb) {
      final list = await _getList(_keyExpenses);
      final idx = list.indexWhere((m) => m['id'] == id);
      if (idx != -1) {
        list[idx]['is_deleted'] = 0;
        list[idx]['deleted_at'] = null;
        await _saveList(_keyExpenses, list);
        return 1;
      }
      return 0;
    }
    final db = await database;
    return await db.update(tableExpenses, {
      'is_deleted': 0,
      'deleted_at': null
    }, where: 'id = ?', whereArgs: [id]);
  }

  // Budgets
  Future<List<Budget>> getBudgets() async {
    if (kIsWeb) {
      final list = await _getList(_keyBudgets);
      return list.map((m) => Budget.fromMap(m)).toList();
    }
    final db = await database;
    final res = await db.query(tableBudgets, where: 'is_deleted = 0');
    return res.map((m) => Budget.fromMap(m)).toList();
  }

  Future<int> insertBudget(Budget budget) async {
    if (kIsWeb) {
      final list = await _getList(_keyBudgets);
      final budgetMap = budget.toMap();
      budgetMap['id'] = DateTime.now().millisecondsSinceEpoch;
      list.add(budgetMap);
      await _saveList(_keyBudgets, list);
      return budgetMap['id'] as int;
    }
    final db = await database;
    return await db.insert(tableBudgets, budget.toMap());
  }

  Future<int> updateBudget(Budget budget) async {
    if (kIsWeb) {
      final list = await _getList(_keyBudgets);
      final idx = list.indexWhere((m) => m['id'] == budget.id);
      if (idx != -1) {
        list[idx] = budget.toMap();
        await _saveList(_keyBudgets, list);
        return 1;
      }
      return 0;
    }
    final db = await database;
    return await db.update(tableBudgets, budget.toMap(), where: 'id = ?', whereArgs: [budget.id]);
  }

  Future<int> deleteBudget(int id) async {
    if (kIsWeb) {
      final list = await _getList(_keyBudgets);
      final idx = list.indexWhere((m) => m['id'] == id);
      if (idx != -1) {
        list[idx]['is_deleted'] = 1;
        list[idx]['deleted_at'] = DateTime.now().toIso8601String();
        await _saveList(_keyBudgets, list);
        return 1;
      }
      return 0;
    }
    final db = await database;
    return await db.update(tableBudgets, {
      'is_deleted': 1,
      'deleted_at': DateTime.now().toIso8601String()
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> saveBudget(Budget budget) async {
    if (budget.id == null) {
      return insertBudget(budget);
    } else {
      return updateBudget(budget);
    }
  }

  // Settings
  Future<UserSettings> getSettings() async {
    if (kIsWeb) {
      final p = await _prefs;
      final raw = p.getString('settings_data');
      if (raw == null) {
        return UserSettings.defaultSettings();
      }
      return UserSettings.fromJson(raw);
    }
    final db = await database;
    final maps = await db.query(tableSettings, limit: 1);
    if (maps.isEmpty) {
      return UserSettings.defaultSettings();
    }
    return UserSettings.fromMap(maps.first);
  }

  Future<void> saveSettings(UserSettings s) async {
    if (kIsWeb) {
      final p = await _prefs;
      await p.setString('settings_data', s.toJson());
      return;
    }
    final db = await database;
    await db.insert(tableSettings, s.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Recurring
  Future<int> insertRecurring(RecurringTransaction r) async {
    if (kIsWeb) {
      final list = await _getList(_keyRecurring);
      list.add(r.toMap());
      await _saveList(_keyRecurring, list);
      return 1;
    }
    final db = await database;
    return await db.insert(tableRecurring, r.toMap());
  }

  Future<List<RecurringTransaction>> getActiveRecurring() async {
    if (kIsWeb) {
      final list = await _getList(_keyRecurring);
      return list.where((m) => m['is_deleted'] != 1 && m['isActive'] == 1).map((m) => RecurringTransaction.fromMap(m)).toList();
    }
    final db = await database;
    final res = await db.query('active_recurring');
    return res.map((m) => RecurringTransaction.fromMap(m)).toList();
  }

  Future<int> updateRecurring(RecurringTransaction r) async {
    if (kIsWeb) {
      final list = await _getList(_keyRecurring);
      for (int i = 0; i < list.length; i++) {
        if (list[i]['id'] == r.id) {
          list[i] = r.toMap();
        }
      }
      await _saveList(_keyRecurring, list);
      return 1;
    }
    final db = await database;
    return db.update(tableRecurring, r.toMap(), where: 'id = ?', whereArgs: [r.id]);
  }

  Future<Map<String, double>> getBalanceSummary() async {
    final expenses = await getAllExpenses();
    double income = 0;
    double expense = 0;
    for (var e in expenses) {
      if (e.type == 'income') {
        income += e.amount;
      }
      if (e.type == 'expense') {
        expense += e.amount;
      }
    }
    return {
      'income': income / 100,
      'expense': expense / 100,
      'balance': (income - expense) / 100,
    };
  }

  Future<List<Map<String, dynamic>>> getCategoryWiseSpending(DateTime month) async {
    final expenses = await getAllExpenses();
    final Map<String, int> totals = {};
    for (var e in expenses) {
      if (e.type == 'expense') {
        if (e.date.year == month.year && e.date.month == month.month) {
          totals[e.category] = (totals[e.category] ?? 0) + e.amount;
        }
      }
    }
    return totals.entries.map((e) => {'category': e.key, 'total': e.value}).toList()..sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));
  }

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

  Future _onConfigure(Database db) async {
    if (!kIsWeb) {
      await db.execute('PRAGMA foreign_keys = ON');
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS $tableCategories (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, icon TEXT NOT NULL,
      type TEXT NOT NULL, color INTEGER NOT NULL, is_default INTEGER DEFAULT 0,
      is_active INTEGER DEFAULT 1, sort_order INTEGER DEFAULT 0, created_at TEXT NOT NULL)''');
    
    final categories = ['Rent', 'Groceries', 'Eating Out', 'Transport', 'Tuition & Fees', 'Textbooks', 'Subscriptions', 'Going Out', 'Health', 'Clothing', 'Tech', 'Other'];
    for (var name in categories) {
      await db.insert(tableCategories, {
        'id': name.toLowerCase().replaceAll(' ', '_').replaceAll('&', '').replaceAll('__', '_'),
        'name': name,
        'icon': _getIconForCategory(name),
        'type': 'expense',
        'color': _getColorForCategory(name),
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String()
      });
    }

    await db.execute('''CREATE TABLE IF NOT EXISTS $tableExpenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, amount INTEGER NOT NULL,
      category TEXT NOT NULL, date TEXT NOT NULL, type TEXT NOT NULL, note TEXT,
      paymentMethod TEXT, receipt TEXT, createdAt TEXT NOT NULL, updatedAt TEXT NOT NULL,
      is_deleted INTEGER DEFAULT 0, deleted_at TEXT, recurring_id TEXT, category_id TEXT)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS $tableBudgets (
      id INTEGER PRIMARY KEY AUTOINCREMENT, categoryId TEXT NOT NULL, amount INTEGER NOT NULL,
      period TEXT NOT NULL, startDate TEXT NOT NULL, endDate TEXT NOT NULL,
      isActive INTEGER DEFAULT 1, is_deleted INTEGER DEFAULT 0, deleted_at TEXT,
      isAllowance INTEGER NOT NULL DEFAULT 0)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS $tableSettings (
      id INTEGER PRIMARY KEY DEFAULT 1, currency TEXT, theme TEXT, language TEXT,
      budgetAlertPercentage REAL, enableNotifications INTEGER, enableBiometric INTEGER,
      monthlyAllowance INTEGER DEFAULT 0, subscriptionTier TEXT NOT NULL DEFAULT 'free',
      subscriptionExpiresAt TEXT)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS $tableRecurring (
      id TEXT PRIMARY KEY, templateTitle TEXT NOT NULL, amount INTEGER NOT NULL,
      categoryId TEXT NOT NULL, type TEXT NOT NULL, frequency INTEGER NOT NULL,
      interval INTEGER NOT NULL, startDate TEXT NOT NULL, endDate TEXT,
      dayOfMonth INTEGER, dayOfWeek INTEGER, monthOfYear INTEGER,
      lastGeneratedDate TEXT, nextDueDate TEXT NOT NULL, isActive INTEGER DEFAULT 1,
      isPaused INTEGER DEFAULT 0, skipDates TEXT, totalGenerated INTEGER DEFAULT 0,
      note TEXT, createdAt TEXT NOT NULL, is_deleted INTEGER DEFAULT 0, deleted_at TEXT)''');
    
    await db.execute('CREATE VIEW IF NOT EXISTS active_expenses AS SELECT * FROM $tableExpenses WHERE is_deleted = 0');
    await db.execute('CREATE VIEW IF NOT EXISTS active_categories AS SELECT * FROM $tableCategories WHERE is_active = 1');
    await db.execute('CREATE VIEW IF NOT EXISTS active_recurring AS SELECT * FROM $tableRecurring WHERE is_deleted = 0 AND isActive = 1');
    
    await db.execute('''CREATE TABLE IF NOT EXISTS parent_links (
      id TEXT PRIMARY KEY, accessCode TEXT NOT NULL,
      isActive INTEGER NOT NULL DEFAULT 1,
      createdAt TEXT NOT NULL, expiresAt TEXT NOT NULL
    )''');
    
    await db.insert(tableSettings, UserSettings.defaultSettings().toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE $tableSettings ADD COLUMN monthlyAllowance INTEGER DEFAULT 0');
      await db.execute("ALTER TABLE budgets ADD COLUMN isAllowance INTEGER NOT NULL DEFAULT 0");
    }
    if (oldVersion < 7) {
      await db.execute('''CREATE TABLE IF NOT EXISTS parent_links (
        id TEXT PRIMARY KEY, accessCode TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL, expiresAt TEXT NOT NULL
      )''');
    }
    if (oldVersion < 8) {
      await db.execute("ALTER TABLE $tableSettings ADD COLUMN subscriptionTier TEXT NOT NULL DEFAULT 'free'");
      await db.execute("ALTER TABLE $tableSettings ADD COLUMN subscriptionExpiresAt TEXT");
    }
  }
}
