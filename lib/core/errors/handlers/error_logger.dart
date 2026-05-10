import 'package:flutter/foundation.dart';
import '../exceptions/app_exception.dart';

/// A utility class for logging exceptions across the application.
/// 
/// This class centralizes error logging logic, allowing for easy integration
/// with external logging services like Sentry or Firebase Crashlytics in the future.
class ErrorLogger {
  /// Logs an [AppException] to the appropriate output.
  /// 
  /// In debug mode, it prints a formatted error report to the console.
  /// In production, this can be extended to send reports to a remote service.
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
