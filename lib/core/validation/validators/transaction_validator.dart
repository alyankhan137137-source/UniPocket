import '../validation_result.dart';
import 'amount_validator.dart';

class TransactionValidator {
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
    if (date.isAfter(now.add(const Duration(minutes: 1)))) {
      return ValidationResult.invalid("Future dates are not allowed", fieldName: "date", errorCode: ValidationErrorCode.futureDate);
    }
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
