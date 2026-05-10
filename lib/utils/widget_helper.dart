import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import 'package:intl/intl.dart';

/// A utility class for updating external app widgets (e.g., Home Screen widgets).
/// 
/// This class handles the communication between the app's internal state and 
/// platform-specific widget providers (Android Widgets / iOS Widgets).
class WidgetHelper {
  /// Updates the home screen widget with the current balance and transaction summary.
  /// 
  /// [balance], [income], and [expense] are provided in major currency units.
  /// Note: Currently, this logic is bypassed on Web.
  static Future<void> updateBalanceWidget({
    required double balance,
    required double income,
    required double expense,
  }) async {
    if (kIsWeb) return;
    // TODO: Implement platform-specific widget update logic (e.g., using HomeWidget package)
    debugPrint('Widget update: balance=$balance, income=$income, expense=$expense');
  }

  /// Updates the recent transactions section of the home screen widget.
  /// 
  /// [recent] is a list of the latest [Expense] objects to be displayed.
  /// Note: Currently, this logic is bypassed on Web.
  static Future<void> updateRecentTransactionsWidget(List<Expense> recent) async {
    if (kIsWeb) return;
    if (recent.isEmpty) return;
    final last = recent.first;
    debugPrint('Recent tx: ${last.title} - ${NumberFormat.simpleCurrency().format(last.amount / 100.0)}');
  }
}
