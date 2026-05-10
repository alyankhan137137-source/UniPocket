import 'package:flutter/material.dart';
import '../models/recurring_transaction.dart';
import '../services/recurring_service.dart';
import '../../../database/database_helper.dart';

/// A provider that manages the state and lifecycle of recurring transaction templates.
/// 
/// This class handles loading templates from the database, triggering the 
/// generation of due transactions via [RecurringService], and performing 
/// CRUD operations on templates.
class RecurringProvider with ChangeNotifier {
  final RecurringService _service = RecurringService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<RecurringTransaction> _templates = [];
  bool _isLoading = false;

  /// The list of active recurring transaction templates.
  List<RecurringTransaction> get templates => _templates;
  
  /// Whether the provider is currently fetching data from the database.
  bool get isLoading => _isLoading;

  /// Fetches all non-deleted recurring templates from the database.
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

  /// Triggers the background service to check for and generate any due transactions.
  /// 
  /// If any transactions were generated, it reloads the templates to reflect
  /// updated `nextDueDate` or `lastGeneratedDate` values.
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

  /// Adds a new recurring transaction template to the database.
  Future<void> addTemplate(RecurringTransaction template) async {
    await _dbHelper.insertRecurring(template);
    await loadTemplates();
  }

  /// Marks a template as deleted (soft delete) in the database.
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

  /// Toggles the pause state of a recurring template.
  Future<void> togglePause(RecurringTransaction template) async {
    await _dbHelper.updateRecurring(template.copyWith(isPaused: !template.isPaused));
    await loadTemplates();
  }
}
