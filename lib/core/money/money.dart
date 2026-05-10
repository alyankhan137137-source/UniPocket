import 'package:intl/intl.dart';
import 'currency.dart';
import 'currency_list.dart';

/// Represents a monetary value stored as minor units (cents) to avoid floating point errors.
/// 
/// This class provides immutable monetary values and includes support for arithmetic,
/// comparison, and formatting. It uses [int] to store the amount in minor units
/// (e.g., 100 for \$1.00 USD) to ensure precision.
class Money {
  /// The amount in minor units (e.g., cents for USD).
  final int minorUnits;
  
  /// The [Currency] associated with this money object.
  final Currency currency;

  const Money._(this.minorUnits, this.currency);

  // --- Factory Constructors ---

  /// Creates a [Money] instance from minor units.
  /// 
  /// [amount] is the value in minor units (e.g., cents).
  /// [currencyCode] defaults to 'USD'.
  factory Money.fromMinorUnits(int amount, {String currencyCode = 'USD'}) {
    return Money._(amount, CurrencyList.getByCode(currencyCode));
  }

  /// Creates a [Money] instance from a decimal (double) value.
  /// 
  /// [amount] is the major unit value (e.g., 10.50 for \$10.50).
  /// [currencyCode] defaults to 'USD'.
  factory Money.fromDecimal(double amount, {String currencyCode = 'USD'}) {
    final currency = CurrencyList.getByCode(currencyCode);
    final int minorUnits = (amount * currency.subUnitFactor).round();
    return Money._(minorUnits, currency);
  }

  /// Creates a [Money] instance by parsing a string.
  /// 
  /// It removes non-numeric characters (except decimal points) before parsing.
  factory Money.fromString(String amount, {String currencyCode = 'USD'}) {
    final double value = double.tryParse(amount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    return Money.fromDecimal(value, currencyCode: currencyCode);
  }

  /// Represents a zero monetary value.
  static final Money zero = Money._(0, CurrencyList.all[0]);

  // --- Arithmetic Operations ---

  /// Adds two [Money] instances. Throws [ArgumentError] if currencies differ.
  Money operator +(Money other) {
    _checkSameCurrency(other);
    return Money._(minorUnits + other.minorUnits, currency);
  }

  /// Subtracts another [Money] instance from this one. Throws [ArgumentError] if currencies differ.
  Money operator -(Money other) {
    _checkSameCurrency(other);
    return Money._(minorUnits - other.minorUnits, currency);
  }

  /// Multiplies the amount by a [multiplier] and rounds the result.
  Money operator *(num multiplier) {
    return Money._((minorUnits * multiplier).round(), currency);
  }

  /// Divides the amount by a [divisor] and rounds the result.
  Money operator /(num divisor) {
    return Money._((minorUnits / divisor).round(), currency);
  }

  // --- Comparison Operators ---

  /// Checks if this amount is greater than [other]. Throws [ArgumentError] if currencies differ.
  bool operator >(Money other) {
    _checkSameCurrency(other);
    return minorUnits > other.minorUnits;
  }

  /// Checks if this amount is less than [other]. Throws [ArgumentError] if currencies differ.
  bool operator <(Money other) {
    _checkSameCurrency(other);
    return minorUnits < other.minorUnits;
  }

  /// Checks if this amount is greater than or equal to [other]. Throws [ArgumentError] if currencies differ.
  bool operator >=(Money other) {
    _checkSameCurrency(other);
    return minorUnits >= other.minorUnits;
  }

  /// Checks if this amount is less than or equal to [other]. Throws [ArgumentError] if currencies differ.
  bool operator <=(Money other) {
    _checkSameCurrency(other);
    return minorUnits <= other.minorUnits;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money && runtimeType == other.runtimeType && minorUnits == other.minorUnits && currency == other.currency;

  @override
  int get hashCode => minorUnits.hashCode ^ currency.hashCode;

  // --- Getters ---

  /// Returns the value as a decimal (e.g., 10.50).
  double get asDecimal => minorUnits / currency.subUnitFactor;
  
  /// Returns true if the amount is greater than zero.
  bool get isPositive => minorUnits > 0;
  
  /// Returns true if the amount is less than zero.
  bool get isNegative => minorUnits < 0;
  
  /// Returns true if the amount is exactly zero.
  bool get isZero => minorUnits == 0;
  
  /// Returns a new [Money] instance with the absolute value of the current amount.
  Money get abs => Money._(minorUnits.abs(), currency);

  // --- Formatting ---

  /// Returns a formatted string representation of the money.
  /// 
  /// [showSymbol] determines if the currency symbol should be included.
  String toDisplayString({bool showSymbol = true}) {
    final format = NumberFormat.currency(
      symbol: showSymbol ? currency.symbol : '',
      decimalDigits: currency.decimalDigits,
    );
    return format.format(asDecimal);
  }

  @override
  String toString() => toDisplayString();

  // --- Private Helpers ---

  void _checkSameCurrency(Money other) {
    if (currency.code != other.currency.code) {
      throw ArgumentError('Currencies do not match: ${currency.code} vs ${other.currency.code}');
    }
  }
}
