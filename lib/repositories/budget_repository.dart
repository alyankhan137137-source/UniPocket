import '../database/database_helper.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final DatabaseHelper _dbHelper;

  BudgetRepository(this._dbHelper);

  Future<List<Budget>> getBudgets() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.tableBudgets);
    return maps.map((m) => Budget.fromMap(m)).toList();
  }

  Future<int> addBudget(Budget budget) async {
    final db = await _dbHelper.database;
    return await db.insert(DatabaseHelper.tableBudgets, budget.toMap());
  }

  Future<int> updateBudget(Budget budget) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseHelper.tableBudgets,
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(DatabaseHelper.tableBudgets, where: 'id = ?', whereArgs: [id]);
  }
}
