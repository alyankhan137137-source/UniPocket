import '../validation_result.dart';
import '../sanitizers/input_sanitizer.dart';

class AmountValidator {
  static const double maxAmount = 9999999.99;

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
