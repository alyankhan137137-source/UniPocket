import 'dart:math';

class Currency {
  final String code;
  final String symbol;
  final int decimalDigits;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.decimalDigits,
    required this.name,
  });

  /// Returns the factor to convert from major to minor units (e.g., 100 for USD)
  num get subUnitFactor => pow(10, decimalDigits);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}
