import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';

/// A provider that manages transaction categories, including default and custom types.
/// 
/// This provider handles the lifecycle of categories, providing different lists 
/// for income and expenses, and managing persistence on Web via [SharedPreferences].
class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  static const String _key = 'pt_categories';

  /// The complete list of available categories.
  List<CategoryModel> get categories => _categories;
  
  /// A filtered list containing only expense-related categories.
  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.type == CategoryType.expense).toList();
  
  /// A filtered list containing only income-related categories.
  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => c.type == CategoryType.income).toList();
  
  /// Whether the provider is currently loading category data.
  bool get isLoading => _isLoading;
  
  /// The last error message encountered during category operations.
  String? get error => _error;

  CategoryProvider() {
    loadCategories();
  }

  // ── Default categories (always available) ────────────────────────
  
  /// A static list of system-default categories used to seed the application.
  static List<CategoryModel> get _defaults {
    final now = DateTime.now();
    return [
      // Expense
      CategoryModel(id:'1',  name:'Food & Dining',    icon:'🍔', color:0xFFE53935, type:CategoryType.expense, isDefault:true, sortOrder:1,  createdAt:now),
      CategoryModel(id:'2',  name:'Transport',         icon:'🚗', color:0xFF1E88E5, type:CategoryType.expense, isDefault:true, sortOrder:2,  createdAt:now),
      CategoryModel(id:'3',  name:'Shopping',          icon:'🛍️', color:0xFF8E24AA, type:CategoryType.expense, isDefault:true, sortOrder:3,  createdAt:now),
      CategoryModel(id:'4',  name:'Bills & Utilities', icon:'💡', color:0xFFFF6F00, type:CategoryType.expense, isDefault:true, sortOrder:4,  createdAt:now),
      CategoryModel(id:'5',  name:'Health',            icon:'🏥', color:0xFF00897B, type:CategoryType.expense, isDefault:true, sortOrder:5,  createdAt:now),
      CategoryModel(id:'6',  name:'Entertainment',     icon:'🎬', color:0xFFF4511E, type:CategoryType.expense, isDefault:true, sortOrder:6,  createdAt:now),
      CategoryModel(id:'7',  name:'Education',         icon:'📚', color:0xFF3949AB, type:CategoryType.expense, isDefault:true, sortOrder:7,  createdAt:now),
      CategoryModel(id:'8',  name:'Rent',              icon:'🏠', color:0xFF6D4C41, type:CategoryType.expense, isDefault:true, sortOrder:8,  createdAt:now),
      CategoryModel(id:'9',  name:'Groceries',         icon:'🛒', color:0xFF43A047, type:CategoryType.expense, isDefault:true, sortOrder:9,  createdAt:now),
      CategoryModel(id:'10', name:'Other',             icon:'📦', color:0xFF757575, type:CategoryType.expense, isDefault:true, sortOrder:10, createdAt:now),
      // Income
      CategoryModel(id:'11', name:'Salary',     icon:'💼', color:0xFF43A047, type:CategoryType.income, isDefault:true, sortOrder:1, createdAt:now),
      CategoryModel(id:'12', name:'Freelance',  icon:'💻', color:0xFF00ACC1, type:CategoryType.income, isDefault:true, sortOrder:2, createdAt:now),
      CategoryModel(id:'13', name:'Business',   icon:'🏢', color:0xFF1E88E5, type:CategoryType.income, isDefault:true, sortOrder:3, createdAt:now),
      CategoryModel(id:'14', name:'Investment', icon:'📈', color:0xFF8E24AA, type:CategoryType.income, isDefault:true, sortOrder:4, createdAt:now),
      CategoryModel(id:'15', name:'Gift',       icon:'🎁', color:0xFFE53935, type:CategoryType.income, isDefault:true, sortOrder:5, createdAt:now),
      CategoryModel(id:'16', name:'Other',      icon:'📦', color:0xFF757575, type:CategoryType.income, isDefault:true, sortOrder:6, createdAt:now),
    ];
  }

  // ── Load ─────────────────────────────────────────────────────────
  
  /// Loads categories from the database or local storage.
  /// 
  /// On Web, it retrieves from [SharedPreferences] and ensures defaults are present.
  /// On Mobile, it currently falls back to defaults (SQLite integration pending).
  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (kIsWeb) {
        final p   = await SharedPreferences.getInstance();
        final raw = p.getString(_key);
        if (raw == null) {
          // First run — seed defaults
          _categories = _defaults;
          await _saveWeb(_categories);
        } else {
          final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
          _categories = list.map((m) => CategoryModel.fromMap(m)).toList();
          // Always make sure defaults are present
          for (final d in _defaults) {
            if (!_categories.any((c) => c.id == d.id)) {
              _categories.add(d);
            }
          }
          await _saveWeb(_categories);
        }
      } else {
        // Mobile — use built-in defaults directly
        _categories = _defaults;
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      _categories = _defaults; // fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Internal helper to persist the category list on Web.
  Future<void> _saveWeb(List<CategoryModel> list) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(list.map((c) => c.toMap()).toList()));
  }

  // ── Add ──────────────────────────────────────────────────────────
  
  /// Adds a new custom [category] to the list.
  Future<void> addCategory(CategoryModel category) async {
    try {
      _categories.add(category.copyWith(isDefault: false));
      if (kIsWeb) await _saveWeb(_categories);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add category: $e';
      notifyListeners();
    }
  }

  // ── Update ───────────────────────────────────────────────────────
  
  /// Updates an existing custom [category].
  /// 
  /// Note: System-default categories cannot be modified.
  Future<void> updateCategory(CategoryModel category) async {
    if (category.isDefault) {
      _error = 'Default categories cannot be modified.';
      notifyListeners();
      return;
    }
    try {
      final idx = _categories.indexWhere((c) => c.id == category.id);
      if (idx != -1) _categories[idx] = category;
      if (kIsWeb) await _saveWeb(_categories);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update category: $e';
      notifyListeners();
    }
  }

  // ── Delete ───────────────────────────────────────────────────────
  
  /// Removes a custom category from the application.
  /// 
  /// Returns true if deletion was successful.
  /// Note: System-default categories cannot be deleted.
  Future<bool> deleteCategory(String id) async {
    final cat = _categories.firstWhere((c) => c.id == id,
        orElse: () => _defaults.first);
    if (cat.isDefault) {
      _error = 'Default categories cannot be deleted.';
      notifyListeners();
      return false;
    }
    try {
      _categories.removeWhere((c) => c.id == id);
      if (kIsWeb) await _saveWeb(_categories);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete category: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Stats ────────────────────────────────────────────────────────
  
  /// Returns the number of times a category has been used in the given [expenses] list.
  int getCategoryUsageCount(String name, List<Expense> expenses) =>
      expenses.where((e) => e.category == name).length;

  /// Returns a list of categories sorted by their usage frequency.
  /// 
  /// [limit] constrains the number of results returned.
  List<Map<String, dynamic>> getMostUsedCategories(List<Expense> expenses,
      {int limit = 5}) {
    final Map<String, int> map = {};
    for (var e in expenses) map[e.category] = (map[e.category] ?? 0) + 1;
    return (map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(limit)
        .map((e) => {'category': e.key, 'count': e.value})
        .toList();
  }
}
