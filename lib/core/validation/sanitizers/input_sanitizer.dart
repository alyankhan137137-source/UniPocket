/// A utility class for cleaning and normalizing user input.
///
/// This class provides methods to prevent common issues like XSS,
/// unnecessary whitespace, and overly long inputs by sanitizing strings
/// before they are processed or saved.
class InputSanitizer {
  InputSanitizer._();

  /// Removes HTML tags, trims whitespace, and normalizes spaces.
  ///
  /// [input] is the raw string to sanitize.
  /// [maxLength] is an optional limit to the length of the resulting string.
  static String sanitizeString(String input, {int? maxLength}) {
    String result = input;

    // 1. Remove control characters and null bytes
    result = result.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    // 2. Strip HTML tags (basic implementation)
    result = result.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');

    // 3. Normalize whitespace (multiple spaces to single space)
    result = result.replaceAll(RegExp(r'\s+'), ' ');

    // 4. Trim leading/trailing whitespace
    result = result.trim();

    // 5. Limit length
    if (maxLength != null && result.length > maxLength) {
      result = result.substring(0, maxLength);
    }

    return result;
  }

  /// Sanitizes a list of tags.
  ///
  /// Trims each tag, removes empty ones, and limits the total number of tags
  /// as well as individual tag lengths.
  static List<String> sanitizeTags(List<String> tags, {int maxTags = 10, int maxTagLength = 30}) {
    return tags
        .map((tag) => sanitizeString(tag, maxLength: maxTagLength))
        .where((tag) => tag.isNotEmpty)
        .take(maxTags)
        .toList();
  }

  /// Basic numeric string cleanup.
  ///
  /// Removes all characters except digits, dots, and commas.
  static String sanitizeNumeric(String input) {
    // Allow digits, one dot or one comma
    return input.replaceAll(RegExp(r'[^0-9.,]'), '');
  }
}
