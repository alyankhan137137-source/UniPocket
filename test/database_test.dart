import 'package:flutter_test/flutter_test.dart';
import 'package:pockettrack_lite/database/database_helper.dart';
import 'package:pockettrack_lite/models/expense_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  // Initialize sqflite_ffi for local unit testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseHelper dbHelper;

  setUp(() {
    dbHelper = DatabaseHelper();
  });

  group('Database Integration Tests', () {
    test('Insert and Retrieve Expense', () async {
      final expense = Expense(
        title: 'Test Expense',
        amount: 50,
        category: 'Food',
        date: DateTime.now(),
        type: 'expense',
      );

      final id = await dbHelper.insertExpense(expense);
      expect(id, isNotNull);

      final expenses = await dbHelper.getAllExpenses();
      expect(expenses.any((e) => e.title == 'Test Expense'), true);
    });

    test('Update Expense', () async {
      // First ensure there is an expense to update
      await dbHelper.insertExpense(Expense(
        title: 'Original',
        amount: 10,
        category: 'Food',
        date: DateTime.now(),
        type: 'expense',
      ));
      
      final expenses = await dbHelper.getAllExpenses();
      final original = expenses.first;
      final updated = original.copyWith(title: 'Updated Title');
      
      await dbHelper.updateExpense(updated);
      final refreshed = await dbHelper.getAllExpenses();
      expect(refreshed.any((e) => e.title == 'Updated Title'), true);
    });

    test('Delete Expense', () async {
      final id = await dbHelper.insertExpense(Expense(
        title: 'ToDelete',
        amount: 10,
        category: 'Food',
        date: DateTime.now(),
        type: 'expense',
      ));
      
      // FIX: Use softDeleteExpense to match DatabaseHelper implementation
      await dbHelper.softDeleteExpense(id);
      
      final refreshed = await dbHelper.getAllExpenses();
      expect(refreshed.any((e) => e.id == id), false);
    });

    test('Balance Summary Calculation', () async {
      await dbHelper.clearAllData();
      
      await dbHelper.insertExpense(Expense(
        title: 'Income', amount: 100000, category: 'Salary', 
        date: DateTime.now(), type: 'income'
      ));
      
      await dbHelper.insertExpense(Expense(
        title: 'Expense', amount: 40000, category: 'Rent', 
        date: DateTime.now(), type: 'expense'
      ));

      final summary = await dbHelper.getBalanceSummary();
      // Values are divided by 100 in getBalanceSummary for display
      expect(summary['income'], 1000.0);
      expect(summary['expense'], 400.0);
      expect(summary['balance'], 600.0);
    });
  });
}
