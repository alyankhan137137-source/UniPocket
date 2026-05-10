import 'package:flutter/material.dart';
import 'dart:ui';
import '../exceptions/app_exception.dart';
import 'error_logger.dart';

/// A centralized handler for catching and processing uncaught errors in the application.
/// 
/// This class configures global error hooks for the Flutter framework and the 
/// underlying platform dispatcher. It ensures that all unexpected errors are
/// logged and can be handled gracefully.
class GlobalErrorHandler {
  /// Initializes global error handling hooks.
  /// 
  /// Should be called early in the application lifecycle (e.g., in `main()`).
  static void init() {
    // Catch errors from the Flutter framework (UI thread errors)
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack);
    };

    // Catch errors from the platform/isolates (Async errors)
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack);
      return true;
    };
  }

  /// Maps a raw error to an [AppException] and logs it.
  static void _logError(dynamic error, StackTrace? stack) {
    final appException = error is AppException
        ? error
        : AppException(
            message: error.toString(),
            stackTrace: stack,
          );
    
    ErrorLogger.log(appException);
  }

  /// Wraps a critical asynchronous operation with error handling logic.
  /// 
  /// Any exception thrown during the [action] will be logged automatically.
  static Future<void> handle(Future<void> Function() action) async {
    try {
      await action();
    } catch (e, stack) {
      _logError(e, stack);
    }
  }
}
