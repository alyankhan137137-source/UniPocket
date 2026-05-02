import '../database/database_helper.dart';
import '../models/expense_model.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper;

  TransactionRepository(this._dbHelper);

  Future<List<Expense>> getTransactions({int? limit, int? offset}) {
    return _dbHelper.getAllExpenses(limit: limit, offset: offset);
  }

  Future<int> addTransaction(Expense expense) {
    return _dbHelper.insertExpense(expense);
  }

  Future<int> updateTransaction(Expense expense) {
    return _dbHelper.updateExpense(expense);
  }

  Future<int> deleteTransaction(int id) {
    return _dbHelper.softDeleteExpense(id);
  }

  Future<Map<String, double>> getBalanceSummary() {
    return _dbHelper.getBalanceSummary();
  }

  Future<List<Map<String, dynamic>>> getCategoryWiseSpending(DateTime month) {
    return _dbHelper.getCategoryWiseSpending(month);
  }
}
