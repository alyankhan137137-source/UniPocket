import 'package:intl/intl.dart';

/// A utility class for consistent data formatting across the application.
/// 
/// This class provides static methods to format numeric values as currency 
/// and dates into user-friendly strings.
class Formatters {
  /// Formats a numeric [amount] as a currency string using the simple currency format.
  /// 
  /// Example: 10.5 -> "$10.50"
  static String formatCurrency(double amount) {
    return NumberFormat.simpleCurrency().format(amount);
  }

  /// Formats a [DateTime] object into a shortened date string.
  /// 
  /// Example: DateTime(2023, 10, 27) -> "Oct 27, 2023"
  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }
}
