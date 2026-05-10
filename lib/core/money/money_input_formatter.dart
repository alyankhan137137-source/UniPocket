import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'currency_list.dart';

/// A [TextInputFormatter] that automatically formats numeric input as currency while typing.
/// 
/// This formatter ensures that the user's input is always displayed in a valid
/// currency format for the specified [currencyCode]. It handles the insertion of
/// decimal points and currency symbols dynamically.
class MoneyInputFormatter extends TextInputFormatter {
  /// The ISO code of the currency to use for formatting (e.g., 'USD').
  final String currencyCode;
  
  /// The maximum allowed numeric value to prevent overflow or unrealistic inputs.
  /// Set to 99,999,999,999 cents ($999,999,999.99).
  final int maxValue = 99999999999;

  MoneyInputFormatter({this.currencyCode = 'USD'});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final currency = CurrencyList.getByCode(currencyCode);
    
    // Only allow digits to extract the raw numeric value
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digitsOnly.isEmpty) return oldValue;
    
    int value = int.parse(digitsOnly);
    
    // Safety check against extremely large numbers
    if (value > maxValue) return oldValue;

    // Calculate the decimal value based on the currency's precision
    final double decimalValue = value / currency.subUnitFactor;
    
    final formatter = NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: currency.decimalDigits,
    );

    // Format the value into a display string
    String newText = formatter.format(decimalValue);

    return newValue.copyWith(
      text: newText,
      // Keep the cursor at the end of the formatted text
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
