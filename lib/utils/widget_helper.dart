import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import 'package:intl/intl.dart';

class WidgetHelper {
  static Future<void> updateBalanceWidget({
    required double balance,
    required double income,
    required double expense,
  }) async {
    if (kIsWeb) return;
    debugPrint('Widget update: balance=$balance, income=$income, expense=$expense');
  }

  static Future<void> updateRecentTransactionsWidget(List<Expense> recent) async {
    if (kIsWeb) return;
    if (recent.isEmpty) return;
    final last = recent.first;
    debugPrint('Recent tx: ${last.title} - ${NumberFormat.simpleCurrency().format(last.amount)}');
  }
}
