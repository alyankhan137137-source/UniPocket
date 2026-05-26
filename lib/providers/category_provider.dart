import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';

/// A provider that manages transaction categories, including default and custom types.
class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  static const String _key = 'up_categories';

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get expenseCategories => _categories.where((c) => c.type == CategoryType.expense).toList();
  List<CategoryModel> get incomeCategories => _categories.where((c) => c.type == CategoryType.income).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  CategoryProvider() {
    loadCategories();
  }

  static List<CategoryModel> get _defaults {
    final now = DateTime.now();
    return [
      // Student Expense Categories
      CategoryModel(id:'1',  name:'Rent',              icon:'🏠', color:0xFF6D4C41, type:CategoryType.expense, isDefault:true, sortOrder:1,  createdAt:now),
      CategoryModel(id:'2',  name:'Groceries',         icon:'🛒', color:0xFF43A047, type:CategoryType.expense, isDefault:true, sortOrder:2,  createdAt:now),
      CategoryModel(id:'3',  name:'Eating Out',        icon:'🍔', color:0xFFE53935, type:CategoryType.expense, isDefault:true, sortOrder:3,  createdAt:now),
      CategoryModel(id:'4',  name:'Transport',         icon:'🚗', color:0xFF1E88E5, type:CategoryType.expense, isDefault:true, sortOrder:4,  createdAt:now),
      CategoryModel(id:'5',  name:'Tuition & Fees',    icon:'🎓', color:0xFF3949AB, type:CategoryType.expense, isDefault:true, sortOrder:5,  createdAt:now),
      CategoryModel(id:'6',  name:'Textbooks',         icon:'📚', color:0xFFFBC02D, type:CategoryType.expense, isDefault:true, sortOrder:6,  createdAt:now),
      CategoryModel(id:'7',  name:'Subscriptions',     icon:'📱', color:0xFF8E24AA, type:CategoryType.expense, isDefault:true, sortOrder:7,  createdAt:now),
      CategoryModel(id:'8',  name:'Going Out',         icon:'🎬', color:0xFFF4511E, type:CategoryType.expense, isDefault:true, sortOrder:8,  createdAt:now),
      CategoryModel(id:'9',  name:'Health',            icon:'🏥', color:0xFF00897B, type:CategoryType.expense, isDefault:true, sortOrder:9,  createdAt:now),
      CategoryModel(id:'10', name:'Clothing',          icon:'🛍️', color:0xFFEC407A, type:CategoryType.expense, isDefault:true, sortOrder:10, createdAt:now),
      CategoryModel(id:'11', name:'Tech',              icon:'💻', color:0xFF00ACC1, type:CategoryType.expense, isDefault:true, sortOrder:11, createdAt:now),
      CategoryModel(id:'12', name:'Other',             icon:'📦', color:0xFF757575, type:CategoryType.expense, isDefault:true, sortOrder:12, createdAt:now),
      // Income Categories
      CategoryModel(id:'13', name:'Allowance',  icon:'💰', color:0xFF43A047, type:CategoryType.income, isDefault:true, sortOrder:1, createdAt:now),
      CategoryModel(id:'14', name:'Part-time',   icon:'💼', color:0xFF1E88E5, type:CategoryType.income, isDefault:true, sortOrder:2, createdAt:now),
      CategoryModel(id:'15', name:'Scholarship',icon:'🎓', color:0xFF3949AB, type:CategoryType.income, isDefault:true, sortOrder:3, createdAt:now),
      CategoryModel(id:'16', name:'Other',      icon:'📥', color:0xFF757575, type:CategoryType.income, isDefault:true, sortOrder:4, createdAt:now),
    ];
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (kIsWeb) {
        final p   = await SharedPreferences.getInstance();
        final raw = p.getString(_key);
        if (raw == null) {
          _categories = _defaults;
          await _saveWeb(_categories);
        } else {
          final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
          _categories = list.map((m) => CategoryModel.fromMap(m)).toList();
          for (final d in _defaults) {
            if (!_categories.any((c) => c.id == d.id)) {
              _categories.add(d);
            }
          }
          await _saveWeb(_categories);
        }
      } else {
        _categories = _defaults;
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      _categories = _defaults;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveWeb(List<CategoryModel> list) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(list.map((c) => c.toMap()).toList()));
  }

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

  Future<bool> deleteCategory(String id) async {
    final cat = _categories.firstWhere((c) => c.id == id, orElse: () => _defaults.first);
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

  int getCategoryUsageCount(String name, List<Expense> expenses) => expenses.where((e) => e.category == name).length;

  List<Map<String, dynamic>> getMostUsedCategories(List<Expense> expenses, {int limit = 5}) {
    final Map<String, int> map = {};
    for (var e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + 1;
    }
    return (map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(limit)
        .map((e) => {'category': e.key, 'count': e.value})
        .toList();
  }
}
