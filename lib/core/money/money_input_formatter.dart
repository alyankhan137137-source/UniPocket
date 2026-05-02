import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'currency_list.dart';

/// A formatter that automatically formats numeric input as currency while typing.
class MoneyInputFormatter extends TextInputFormatter {
  final String currencyCode;
  final int maxValue = 99999999999; // $999,999,999.99

  MoneyInputFormatter({this.currencyCode = 'USD'});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final currency = CurrencyList.getByCode(currencyCode);
    
    // Only allow digits
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digitsOnly.isEmpty) return oldValue;
    
    int value = int.parse(digitsOnly);
    
    if (value > maxValue) return oldValue;

    final double decimalValue = value / currency.subUnitFactor;
    
    final formatter = NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: currency.decimalDigits,
    );

    String newText = formatter.format(decimalValue);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
