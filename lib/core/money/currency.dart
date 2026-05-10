import 'dart:math';

/// Represents a currency configuration with its code, symbol, and precision.
class Currency {
  /// The ISO currency code (e.g., 'USD', 'EUR').
  final String code;
  
  /// The symbol used for display (e.g., '$', '€').
  final String symbol;
  
  /// The number of decimal places this currency uses.
  final int decimalDigits;
  
  /// The full descriptive name of the currency.
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.decimalDigits,
    required this.name,
  });

  /// Returns the factor to convert from major to minor units.
  /// 
  /// For example, returns 100 for USD (2 digits) and 1000 for KWD (3 digits).
  num get subUnitFactor => pow(10, decimalDigits);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}
