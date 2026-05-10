import 'package:flutter/foundation.dart';

/// Base class for all application-specific exceptions.
/// 
/// Provides a common structure for errors, including a technical [message],
/// an optional error [code], [details], and a [stackTrace]. It also generates
/// a [timestamp] upon instantiation.
@immutable
class AppException implements Exception {
  /// Technical error message.
  final String message;
  
  /// Optional machine-readable error code.
  final String? code;
  
  /// Additional contextual information about the error.
  final dynamic details;
  
  /// The stack trace associated with the exception, if available.
  final StackTrace? stackTrace;
  
  /// The time when the exception occurred.
  final DateTime timestamp;

  AppException({
    required this.message,
    this.code,
    this.details,
    this.stackTrace,
  }) : timestamp = DateTime.now();

  @override
  String toString() => 'AppException(message: $message, code: $code, timestamp: $timestamp)';

  /// Returns a user-friendly message based on the exception type.
  /// 
  /// Subclasses should override this to provide localized or more
  /// descriptive messages for the end user.
  String get userMessage => message;
}

/// Exception thrown when a database operation fails.
class DatabaseException extends AppException {
  DatabaseException({required super.message, super.code, super.details, super.stackTrace});

  @override
  String get userMessage => "Something went wrong saving your data. Please try again.";
}

/// Exception thrown when a network-related operation fails.
class NetworkException extends AppException {
  NetworkException({required super.message, super.code, super.details, super.stackTrace});

  @override
  String get userMessage => "Connection issue detected. Your changes will sync when reconnected.";
}

/// Exception thrown when data validation fails.
class ValidationException extends AppException {
  /// The specific field that failed validation.
  final String field;
  
  ValidationException({required this.field, required super.message, super.code, super.details});

  @override
  String get userMessage => "$field: $message";
}

/// Exception thrown during authentication failures.
class AuthException extends AppException {
  AuthException({required super.message, super.code});
  
  @override
  String get userMessage => "Session expired. Please log in again.";
}

/// Exception thrown for business logic violations.
class BusinessException extends AppException {
  BusinessException({required super.message, super.code});
}
