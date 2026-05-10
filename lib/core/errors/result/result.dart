import '../exceptions/app_exception.dart';

/// A class representing the result of an operation, which can either be a [Success] or a [Failure].
/// 
/// This pattern is used to handle errors functionally instead of relying solely on
/// try-catch blocks, making the code more predictable and easier to test.
abstract class Result<T, E extends AppException> {
  const Result();

  /// Returns true if the result is a [Success].
  bool get isSuccess => this is Success<T, E>;
  
  /// Returns true if the result is a [Failure].
  bool get isFailure => this is Failure<T, E>;

  /// Creates a [Success] instance with the provided [data].
  static Result<T, E> success<T, E extends AppException>(T data) => Success(data);
  
  /// Creates a [Failure] instance with the provided [error].
  static Result<T, E> failure<T, E extends AppException>(E error) => Failure(error);

  /// Collapses the [Result] into a single value by calling either [onSuccess] or [onFailure].
  /// 
  /// This is the primary way to consume the result of an operation.
  R fold<R>(R Function(T data) onSuccess, R Function(E error) onFailure) {
    if (this is Success<T, E>) {
      return onSuccess((this as Success<T, E>).data);
    } else {
      return onFailure((this as Failure<T, E>).error);
    }
  }

  /// Maps the success data if it's a [Success], or returns the [Failure] as is.
  /// 
  /// Useful for transforming the data of a successful operation.
  Result<R, E> map<R>(R Function(T data) mapper) {
    if (this is Success<T, E>) {
      return Success(mapper((this as Success<T, E>).data));
    } else {
      return Failure((this as Failure<T, E>).error);
    }
  }

  /// Returns the data if this is a [Success], or null otherwise.
  T? getOrNull() => this is Success<T, E> ? (this as Success<T, E>).data : null;
  
  /// Returns the error if this is a [Failure], or null otherwise.
  E? errorOrNull() => this is Failure<T, E> ? (this as Failure<T, E>).error : null;
}

/// Represents a successful operation result containing [data] of type [T].
class Success<T, E extends AppException> extends Result<T, E> {
  final T data;
  const Success(this.data);
}

/// Represents a failed operation result containing an error of type [E].
class Failure<T, E extends AppException> extends Result<T, E> {
  final E error;
  const Failure(this.error);
}
