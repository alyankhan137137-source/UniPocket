import '../validation_result.dart';
import '../sanitizers/input_sanitizer.dart';

/// A validator for monetary amount inputs.
///
/// This class provides logic to ensure that a given string represents
/// a valid monetary value within acceptable ranges.
class AmountValidator {
  /// The maximum permitted amount for a single transaction.
  static const double maxAmount = 9999999.99;

  /// Validates a string [value] as a monetary amount.
  ///
  /// [allowZero] determines if an amount of exactly 0.0 is considered valid.
  /// Returns a [ValidationResult] indicating success or failure with an error message.
  static ValidationResult validate(String? value, {bool allowZero = false}) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.invalid("Amount cannot be empty", errorCode: ValidationErrorCode.empty);
    }

    // Sanitize and convert locale-specific decimal points
    final sanitized = InputSanitizer.sanitizeNumeric(value).replaceFirst(',', '.');
    final double? amount = double.tryParse(sanitized);

    if (amount == null) {
      return ValidationResult.invalid("Invalid number format", errorCode: ValidationErrorCode.invalidFormat);
    }

    if (!allowZero && amount == 0) {
      return ValidationResult.invalid("Amount must be greater than zero", errorCode: ValidationErrorCode.outOfRange);
    }

    if (amount < 0) {
      return ValidationResult.invalid("Amount cannot be negative", errorCode: ValidationErrorCode.outOfRange);
    }

    if (amount > maxAmount) {
      return ValidationResult.invalid("Amount is too high", errorCode: ValidationErrorCode.outOfRange);
    }

    return ValidationResult.valid();
  }
}
