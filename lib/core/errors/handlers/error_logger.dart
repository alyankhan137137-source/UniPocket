import 'package:flutter/foundation.dart';
import '../exceptions/app_exception.dart';

class ErrorLogger {
  static void log(AppException exception) {
    // 1. Log to console in debug mode with formatting
    if (kDebugMode) {
      debugPrint('\n--- ❌ ERROR LOGGED ---');
      debugPrint('Timestamp: ${exception.timestamp}');
      debugPrint('Message: ${exception.message}');
      if (exception.code != null) debugPrint('Code: ${exception.code}');
      if (exception.stackTrace != null) {
        debugPrint('StackTrace:\n${exception.stackTrace}');
      }
      debugPrint('----------------------\n');
    }

    // 2. Production: Here you would integrate Sentry, Firebase Crashlytics, etc.
    // _logToRemoteService(exception);
  }
}
