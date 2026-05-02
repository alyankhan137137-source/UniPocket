import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double amount) {
    return NumberFormat.simpleCurrency().format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }
}
