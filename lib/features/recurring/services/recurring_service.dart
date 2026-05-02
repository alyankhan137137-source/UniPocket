import '../../../database/database_helper.dart';
import '../../../models/expense_model.dart';
import '../models/recurrence_frequency.dart';

class RecurringService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Checks and generates all due transactions from active recurring templates
  Future<int> generateDueTransactions() async {
    final activeRecurring = await _dbHelper.getActiveRecurring();
    final now = DateTime.now();
    int count = 0;

    for (var recurring in activeRecurring) {
      DateTime nextDue = recurring.nextDueDate;
      
      // Keep generating if we are past the due date (handles app not opened for long time)
      while (nextDue.isBefore(now) || nextDue.isAtSameMomentAs(now)) {
        // 1. Generate the actual transaction
        final expense = Expense(
          title: recurring.templateTitle,
          amount: recurring.amount, // FIX: Use integer cents directly
          category: recurring.categoryId,
          date: nextDue,
          type: recurring.type,
          note: "Auto-generated: ${recurring.note ?? ''}",
        );

        await _dbHelper.insertExpense(expense);
        count++;

        // 2. Calculate next due date
        nextDue = _calculateNextDate(nextDue, recurring.frequency, recurring.interval);

        // 3. Stop if we passed the end date
        if (recurring.endDate != null && nextDue.isAfter(recurring.endDate!)) {
          await _dbHelper.updateRecurring(recurring.copyWith(isActive: false));
          break;
        }
      }

      // 4. Update the template with the new nextDueDate and lastGeneratedDate
      if (nextDue != recurring.nextDueDate) {
        await _dbHelper.updateRecurring(recurring.copyWith(
          nextDueDate: nextDue,
          lastGeneratedDate: DateTime.now(),
          totalGenerated: recurring.totalGenerated + count,
        ));
      }
    }
    return count;
  }

  DateTime _calculateNextDate(DateTime current, RecurrenceFrequency freq, int interval) {
    switch (freq) {
      case RecurrenceFrequency.daily:
        return current.add(Duration(days: interval));
      case RecurrenceFrequency.weekly:
        return current.add(Duration(days: 7 * interval));
      case RecurrenceFrequency.biweekly:
        return current.add(Duration(days: 14 * interval));
      case RecurrenceFrequency.monthly:
        int nextMonth = current.month + interval;
        int nextYear = current.year + (nextMonth - 1) ~/ 12;
        nextMonth = (nextMonth - 1) % 12 + 1;
        int nextDay = current.day > 28 ? 28 : current.day;
        return DateTime(nextYear, nextMonth, nextDay, current.hour, current.minute);
      case RecurrenceFrequency.quarterly:
        return _calculateNextDate(current, RecurrenceFrequency.monthly, 3 * interval);
      case RecurrenceFrequency.yearly:
        return DateTime(current.year + interval, current.month, current.day > 28 ? 28 : current.day);
      case RecurrenceFrequency.custom:
        return current.add(Duration(days: interval));
    }
  }
}
