import 'package:flutter_test/flutter_test.dart';
import 'package:unipocket/models/expense_model.dart';
import 'package:unipocket/models/budget_model.dart';
import 'package:unipocket/models/user_settings_model.dart';

void main() {
  group('Expense Model Tests', () {
    test('Expense.fromMap creates correct object', () {
      final map = {
        'id': 1,
        'title': 'Coffee',
        'amount': 4.5,
        'category': 'Food',
        'date': '2023-10-01T10:00:00.000',
        'type': 'expense',
        'createdAt': '2023-10-01T09:00:00.000',
        'updatedAt': '2023-10-01T09:00:00.000',
      };
      final expense = Expense.fromMap(map);
      expect(expense.id, 1);
      expect(expense.title, 'Coffee');
      expect(expense.amount, 4.5);
      expect(expense.type, 'expense');
    });

    test('Expense.toMap converts to correct map', () {
      final expense = Expense(
        id: 1,
        title: 'Allowance',
        amount: 5000,
        category: 'Work',
        date: DateTime(2023, 10, 1),
        type: 'income',
      );
      final map = expense.toMap();
      expect(map['title'], 'Allowance');
      expect(map['amount'], 5000.0);
      expect(map['type'], 'income');
    });
  });

  group('Budget Model Tests', () {
    test('percentSpent calculation', () {
      final budget = Budget(
        categoryId: 'one',
        amount: 1000,
        spent: 750,
        period: 'monthly',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );
      expect(budget.percentSpent, 75.0);
      expect(budget.isExceeded, false);
    });

    test('isExceeded returns true when over budget', () {
      final budget = Budget(
        categoryId: 'one',
        amount: 500,
        spent: 600,
        period: 'monthly',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );
      expect(budget.isExceeded, true);
    });
  });

  group('UserSettings Model Tests', () {
    test('defaultSettings factory', () {
      final settings = UserSettings.defaultSettings();
      expect(settings.currency, 'USD');
      expect(settings.theme, 'system');
      expect(settings.enableNotifications, true);
    });
  });
}
