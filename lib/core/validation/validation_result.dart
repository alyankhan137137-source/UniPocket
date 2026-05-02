enum ValidationErrorCode {
  none,
  empty,
  invalidFormat,
  tooLong,
  tooShort,
  outOfRange,
  futureDate,
  invalidValue,
  duplicate,
  maliciousContent,
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? fieldName;
  final ValidationErrorCode errorCode;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.fieldName,
    this.errorCode = ValidationErrorCode.none,
  });

  factory ValidationResult.valid() => const ValidationResult(isValid: true);

  factory ValidationResult.invalid(String message, {String? fieldName, ValidationErrorCode errorCode = ValidationErrorCode.invalidValue}) {
    return ValidationResult(
      isValid: false,
      errorMessage: message,
      fieldName: fieldName,
      errorCode: errorCode,
    );
  }
}
