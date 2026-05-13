import 'package:flutter_test/flutter_test.dart';
import 'package:unipocket/database/database_helper.dart';
import 'package:unipocket/models/expense_model.dart';
import 'package:unipocket/models/budget_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  // Initialize sqflite_ffi for local unit testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = DatabaseHelper();
    // Ensure we start with a clean state for each test if needed
    // await dbHelper.clearAllData(); 
  });

  group('Database Integration Tests', () {
    test('Insert and Retrieve Expense', () async {
      final expense = Expense(
        title: 'Lunch at Cafeteria',
        amount: 50,
        category: 'Eating Out',
        date: DateTime.now(),
        type: 'expense',
      );

      final id = await dbHelper.insertExpense(expense);
      expect(id, isNotNull);

      final expenses = await dbHelper.getAllExpenses();
      expect(expenses.any((e) => e.title == 'Lunch at Cafeteria'), true);
    });

    test('Update Expense', () async {
      // First ensure there is an expense to update
      await dbHelper.insertExpense(Expense(
        title: 'Original',
        amount: 10,
        category: 'Groceries',
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
        category: 'Other',
        date: DateTime.now(),
        type: 'expense',
      ));
      
      await dbHelper.softDeleteExpense(id);
      
      final refreshed = await dbHelper.getAllExpenses();
      expect(refreshed.any((e) => e.id == id), false);
    });

    test('Balance Summary Calculation', () async {
      await dbHelper.clearAllData();
      
      await dbHelper.insertExpense(Expense(
        title: 'Part-time Job', amount: 100000, category: 'Part-time', 
        date: DateTime.now(), type: 'income'
      ));
      
      await dbHelper.insertExpense(Expense(
        title: 'Monthly Rent', amount: 40000, category: 'Rent',
        date: DateTime.now(), type: 'expense'
      ));

      final summary = await dbHelper.getBalanceSummary();
      // Values are divided by 100 in getBalanceSummary for display
      expect(summary['income'], 1000.0);
      expect(summary['expense'], 400.0);
      expect(summary['balance'], 600.0);
    });

    group('Budget & Allowance Tests', () {
      test('Insert and Retrieve Monthly Allowance Budget', () async {
        final allowanceBudget = Budget(
          categoryId: 'allowance_master',
          amount: 150000, // $1500.00
          period: 'monthly',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          isAllowance: true,
        );

        final id = await dbHelper.insertBudget(allowanceBudget.toMap());
        expect(id, isNotNull);

        final budgetsData = await dbHelper.getBudgets();
        final budgets = budgetsData.map((m) => Budget.fromMap(m)).toList();
        
        final retrieved = budgets.firstWhere((b) => b.isAllowance == true);
        expect(retrieved.amount, 150000);
        expect(retrieved.categoryId, 'allowance_master');
        expect(retrieved.isAllowance, true);
      });

      test('Regular Budget has isAllowance as false', () async {
        final regularBudget = Budget(
          categoryId: 'groceries',
          amount: 20000,
          period: 'monthly',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          isAllowance: false,
        );

        await dbHelper.insertBudget(regularBudget.toMap());
        
        final budgetsData = await dbHelper.getBudgets();
        final budgets = budgetsData.map((m) => Budget.fromMap(m)).toList();
        
        final retrieved = budgets.firstWhere((b) => b.categoryId == 'groceries');
        expect(retrieved.isAllowance, false);
      });
    });
  });
}
