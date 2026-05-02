import 'package:flutter/foundation.dart';

/// Base class for all application-specific exceptions.
@immutable
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  final StackTrace? stackTrace;
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
  String get userMessage => message;
}

class DatabaseException extends AppException {
  DatabaseException({required super.message, super.code, super.details, super.stackTrace});

  @override
  String get userMessage => "Something went wrong saving your data. Please try again.";
}

class NetworkException extends AppException {
  NetworkException({required super.message, super.code, super.details, super.stackTrace});

  @override
  String get userMessage => "Connection issue detected. Your changes will sync when reconnected.";
}

class ValidationException extends AppException {
  final String field;
  ValidationException({required this.field, required super.message, super.code, super.details});

  @override
  String get userMessage => "$field: $message";
}

class AuthException extends AppException {
  AuthException({required super.message, super.code});
  @override
  String get userMessage => "Session expired. Please log in again.";
}

class BusinessException extends AppException {
  BusinessException({required super.message, super.code});
}
