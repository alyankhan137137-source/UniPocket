import 'package:flutter/material.dart';
import '../models/recurring_transaction.dart';
import '../services/recurring_service.dart';
import '../../../database/database_helper.dart';

class RecurringProvider with ChangeNotifier {
  final RecurringService _service = RecurringService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<RecurringTransaction> _templates = [];
  bool _isLoading = false;

  List<RecurringTransaction> get templates => _templates;
  bool get isLoading => _isLoading;

  Future<void> loadTemplates() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.tableRecurring, where: 'is_deleted = 0');
      _templates = maps.map((m) => RecurringTransaction.fromMap(m)).toList();
    } catch (e) {
      debugPrint("Error loading recurring templates: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAndGenerate() async {
    try {
      int count = await _service.generateDueTransactions();
      if (count > 0) {
        await loadTemplates();
      }
    } catch (e) {
      debugPrint("Error generating recurring transactions: $e");
    }
  }

  Future<void> addTemplate(RecurringTransaction template) async {
    await _dbHelper.insertRecurring(template);
    await loadTemplates();
  }

  Future<void> deleteTemplate(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.tableRecurring,
      {'is_deleted': 1, 'deleted_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadTemplates();
  }

  Future<void> togglePause(RecurringTransaction template) async {
    await _dbHelper.updateRecurring(template.copyWith(isPaused: !template.isPaused));
    await loadTemplates();
  }
}
