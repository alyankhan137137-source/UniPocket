import '../database/database_helper.dart';
import '../models/budget_model.dart';

/// A repository class that manages the persistence and retrieval of budget data.
/// 
/// This class acts as an abstraction layer between the UI/Providers and the 
/// [DatabaseHelper], providing a clean API for budget-related CRUD operations.
class BudgetRepository {
  final DatabaseHelper _dbHelper;

  BudgetRepository(this._dbHelper);

  /// Fetches all budgets from the database.
  /// 
  /// Returns a list of [Budget] objects.
  Future<List<Budget>> getBudgets() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.tableBudgets);
    return maps.map((m) => Budget.fromMap(m)).toList();
  }

  /// Persists a new [budget] record to the database.
  /// 
  /// Returns the ID of the newly inserted record.
  Future<int> addBudget(Budget budget) async {
    final db = await _dbHelper.database;
    return await db.insert(DatabaseHelper.tableBudgets, budget.toMap());
  }

  /// Updates an existing [budget] record in the database.
  /// 
  /// Returns the number of rows affected.
  Future<int> updateBudget(Budget budget) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseHelper.tableBudgets,
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  /// Permanently removes a budget record with the given [id] from the database.
  /// 
  /// Returns the number of rows deleted.
  Future<int> deleteBudget(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(DatabaseHelper.tableBudgets, where: 'id = ?', whereArgs: [id]);
  }
}
