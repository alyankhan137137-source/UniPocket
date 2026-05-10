import '../validation_result.dart';
import 'amount_validator.dart';

/// A validator for transaction entities.
/// 
/// This class ensures that all required fields for a transaction (title, amount, date)
/// meet the application's business rules before being processed or saved.
class TransactionValidator {
  /// Validates the data for a new or existing transaction.
  /// 
  /// [title] is the name of the transaction.
  /// [amount] is the monetary string input.
  /// [date] is the transaction date.
  /// [note] is an optional descriptive string.
  /// 
  /// Returns a [ValidationResult] with the first error encountered, if any.
  static ValidationResult validate({
    required String? title,
    required String? amount,
    required DateTime date,
    String? note,
  }) {
    // 1. Validate Amount
    final amountResult = AmountValidator.validate(amount);
    if (!amountResult.isValid) return amountResult;

    // 2. Validate Title
    if (title == null || title.trim().isEmpty) {
      return ValidationResult.invalid("Title cannot be empty", fieldName: "title", errorCode: ValidationErrorCode.empty);
    }
    if (title.length > 50) {
      return ValidationResult.invalid("Title is too long (max 50)", fieldName: "title", errorCode: ValidationErrorCode.tooLong);
    }

    // 3. Validate Date
    final now = DateTime.now();
    // Allow a small buffer (1 minute) for clock drift
    if (date.isAfter(now.add(const Duration(minutes: 1)))) {
      return ValidationResult.invalid("Future dates are not allowed", fieldName: "date", errorCode: ValidationErrorCode.futureDate);
    }
    // Limit how far back a transaction can be dated (10 years)
    if (date.isBefore(now.subtract(const Duration(days: 365 * 10)))) {
      return ValidationResult.invalid("Date is too old", fieldName: "date", errorCode: ValidationErrorCode.outOfRange);
    }

    // 4. Validate Note
    if (note != null && note.length > 500) {
      return ValidationResult.invalid("Note is too long (max 500)", fieldName: "note", errorCode: ValidationErrorCode.tooLong);
    }

    return ValidationResult.valid();
  }
}
