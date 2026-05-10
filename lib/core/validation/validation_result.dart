/// Possible error codes resulting from a validation operation.
enum ValidationErrorCode {
  /// No error occurred.
  none,

  /// The field is required but was left empty.
  empty,

  /// The input does not match the expected format (e.g., email, phone).
  invalidFormat,

  /// The input exceeds the maximum allowed length.
  tooLong,

  /// The input is shorter than the minimum allowed length.
  tooShort,

  /// The numeric value is outside of the permitted range.
  outOfRange,

  /// The date provided is in the future when a past/present date was expected.
  futureDate,

  /// The value is generally invalid for the specific business logic.
  invalidValue,

  /// The value already exists in the system (e.g., duplicate name).
  duplicate,

  /// The input contains potentially harmful or restricted content.
  maliciousContent,
}

/// Represents the outcome of a validation check.
///
/// Contains information about whether the validation succeeded ([isValid])
/// and, if not, provides an [errorMessage] and an [errorCode].
class ValidationResult {
  /// Whether the validation was successful.
  final bool isValid;

  /// A user-friendly message describing the validation failure.
  final String? errorMessage;

  /// The name of the field that was validated.
  final String? fieldName;

  /// A machine-readable code representing the type of validation error.
  final ValidationErrorCode errorCode;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.fieldName,
    this.errorCode = ValidationErrorCode.none,
  });

  /// Creates a successful [ValidationResult].
  factory ValidationResult.valid() => const ValidationResult(isValid: true);

  /// Creates a failed [ValidationResult] with a message and optional details.
  factory ValidationResult.invalid(String message, {String? fieldName, ValidationErrorCode errorCode = ValidationErrorCode.invalidValue}) {
    return ValidationResult(
      isValid: false,
      errorMessage: message,
      fieldName: fieldName,
      errorCode: errorCode,
    );
  }
}
