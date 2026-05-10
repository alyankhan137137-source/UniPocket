import 'currency.dart';

/// A static repository of supported currencies in the application.
class CurrencyList {
  /// A list of all supported [Currency] objects.
  /// 
  /// This list includes common currencies and covers those with 
  /// varying decimal precision (0, 2, and 3 digits).
  static const List<Currency> all = [
    Currency(code: 'USD', symbol: '\$', decimalDigits: 2, name: 'US Dollar'),
    Currency(code: 'EUR', symbol: '€', decimalDigits: 2, name: 'Euro'),
    Currency(code: 'GBP', symbol: '£', decimalDigits: 2, name: 'British Pound'),
    Currency(code: 'JPY', symbol: '¥', decimalDigits: 0, name: 'Japanese Yen'),
    Currency(code: 'PKR', symbol: '₨', decimalDigits: 2, name: 'Pakistani Rupee'),
    Currency(code: 'INR', symbol: '₹', decimalDigits: 2, name: 'Indian Rupee'),
    Currency(code: 'KWD', symbol: 'د.ك', decimalDigits: 3, name: 'Kuwaiti Dinar'),
    Currency(code: 'AED', symbol: 'د.إ', decimalDigits: 2, name: 'UAE Dirham'),
    Currency(code: 'SAR', symbol: '﷼', decimalDigits: 2, name: 'Saudi Riyal'),
    Currency(code: 'CAD', symbol: 'CA\$', decimalDigits: 2, name: 'Canadian Dollar'),
    Currency(code: 'AUD', symbol: 'AU\$', decimalDigits: 2, name: 'Australian Dollar'),
    Currency(code: 'CNY', symbol: '¥', decimalDigits: 2, name: 'Chinese Yuan'),
    Currency(code: 'BHD', symbol: '.د.ب', decimalDigits: 3, name: 'Bahraini Dinar'),
    Currency(code: 'OMR', symbol: 'ر.ع.', decimalDigits: 3, name: 'Omani Rial'),
  ];

  /// Retrieves a [Currency] by its ISO code.
  /// 
  /// Returns USD as a fallback if the code is not found in the [all] list.
  static Currency getByCode(String code) {
    return all.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => all.first, // Default to USD
    );
  }
}
