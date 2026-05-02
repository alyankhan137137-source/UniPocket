import 'package:flutter/material.dart';
import 'dart:ui';
import '../exceptions/app_exception.dart';
import 'error_logger.dart';

class GlobalErrorHandler {
  static void init() {
    // Catch errors from the Flutter framework
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack);
    };

    // Catch errors from the platform/isolates
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack);
      return true;
    };
  }

  static void _logError(dynamic error, StackTrace? stack) {
    // Map to AppException if it's not already one
    final appException = error is AppException
        ? error
        : AppException(
            message: error.toString(),
            stackTrace: stack,
          );
    
    ErrorLogger.log(appException);
  }

  /// Use this to wrap critical operations
  static Future<void> handle(Future<void> Function() action) async {
    try {
      await action();
    } catch (e, stack) {
      _logError(e, stack);
    }
  }
}
