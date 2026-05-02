class InputSanitizer {
  InputSanitizer._();

  /// Removes HTML tags, trims whitespace, and normalizes spaces.
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
  static List<String> sanitizeTags(List<String> tags, {int maxTags = 10, int maxTagLength = 30}) {
    return tags
        .map((tag) => sanitizeString(tag, maxLength: maxTagLength))
        .where((tag) => tag.isNotEmpty)
        .take(maxTags)
        .toList();
  }

  /// Basic numeric string cleanup.
  static String sanitizeNumeric(String input) {
    // Allow digits, one dot or one comma (will be converted to dot later)
    return input.replaceAll(RegExp(r'[^0-9.,]'), '');
  }
}
