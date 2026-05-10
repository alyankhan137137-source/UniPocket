import '../database/database_helper.dart';
import '../models/expense_model.dart';

/// A repository class that manages financial transaction data.
/// 
/// This class provides an abstraction layer between the UI/Providers and the 
/// [DatabaseHelper], handling CRUD operations for [Expense] (income/expense) records
/// and providing aggregated data for analytics.
class TransactionRepository {
  final DatabaseHelper _dbHelper;

  TransactionRepository(this._dbHelper);

  /// Fetches a list of transactions from the database.
  /// 
  /// Supports pagination through [limit] and [offset].
  /// Returns a list of [Expense] objects.
  Future<List<Expense>> getTransactions({int? limit, int? offset}) {
    return _dbHelper.getAllExpenses(limit: limit, offset: offset);
  }

  /// Persists a new [expense] or income record to the database.
  /// 
  /// Returns the auto-generated ID of the new record.
  Future<int> addTransaction(Expense expense) {
    return _dbHelper.insertExpense(expense);
  }

  /// Updates an existing transaction record in the database.
  /// 
  /// Returns the number of rows affected.
  Future<int> updateTransaction(Expense expense) {
    return _dbHelper.updateExpense(expense);
  }

  /// Marks a transaction as deleted (soft delete) in the database.
  /// 
  /// [id] is the unique identifier of the transaction.
  /// Returns the number of rows affected.
  Future<int> deleteTransaction(int id) {
    return _dbHelper.softDeleteExpense(id);
  }

  /// Retrieves a summary of total income, total expense, and current balance.
  /// 
  /// Values are returned in major currency units.
  Future<Map<String, double>> getBalanceSummary() {
    return _dbHelper.getBalanceSummary();
  }

  /// Calculates total spending grouped by category for a specific [month].
  /// 
  /// Returns a list of maps containing 'category' and 'total' keys.
  Future<List<Map<String, dynamic>>> getCategoryWiseSpending(DateTime month) {
    return _dbHelper.getCategoryWiseSpending(month);
  }
}
