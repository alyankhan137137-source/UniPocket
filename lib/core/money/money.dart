import 'package:intl/intl.dart';
import 'currency.dart';
import 'currency_list.dart';

/// Represents a monetary value stored as minor units (cents) to avoid floating point errors.
class Money {
  final int minorUnits;
  final Currency currency;

  const Money._(this.minorUnits, this.currency);

  // --- Factory Constructors ---

  factory Money.fromMinorUnits(int amount, {String currencyCode = 'USD'}) {
    return Money._(amount, CurrencyList.getByCode(currencyCode));
  }

  factory Money.fromDecimal(double amount, {String currencyCode = 'USD'}) {
    final currency = CurrencyList.getByCode(currencyCode);
    final int minorUnits = (amount * currency.subUnitFactor).round();
    return Money._(minorUnits, currency);
  }

  factory Money.fromString(String amount, {String currencyCode = 'USD'}) {
    final double value = double.tryParse(amount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    return Money.fromDecimal(value, currencyCode: currencyCode);
  }

  static final Money zero = Money._(0, CurrencyList.all[0]);

  // --- Arithmetic Operations ---

  Money operator +(Money other) {
    _checkSameCurrency(other);
    return Money._(minorUnits + other.minorUnits, currency);
  }

  Money operator -(Money other) {
    _checkSameCurrency(other);
    return Money._(minorUnits - other.minorUnits, currency);
  }

  Money operator *(num multiplier) {
    return Money._((minorUnits * multiplier).round(), currency);
  }

  Money operator /(num divisor) {
    return Money._((minorUnits / divisor).round(), currency);
  }

  // --- Comparison Operators ---

  bool operator >(Money other) {
    _checkSameCurrency(other);
    return minorUnits > other.minorUnits;
  }

  bool operator <(Money other) {
    _checkSameCurrency(other);
    return minorUnits < other.minorUnits;
  }

  bool operator >=(Money other) {
    _checkSameCurrency(other);
    return minorUnits >= other.minorUnits;
  }

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

  double get asDecimal => minorUnits / currency.subUnitFactor;
  bool get isPositive => minorUnits > 0;
  bool get isNegative => minorUnits < 0;
  bool get isZero => minorUnits == 0;
  Money get abs => Money._(minorUnits.abs(), currency);

  // --- Formatting ---

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
