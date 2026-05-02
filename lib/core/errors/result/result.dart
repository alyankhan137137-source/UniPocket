import '../exceptions/app_exception.dart';

/// A class representing the result of an operation, which can either be a Success or a Failure.
abstract class Result<T, E extends AppException> {
  const Result();

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;

  static Result<T, E> success<T, E extends AppException>(T data) => Success(data);
  static Result<T, E> failure<T, E extends AppException>(E error) => Failure(error);

  /// Collapses the Result into a single value by calling either [onSuccess] or [onFailure].
  R fold<R>(R Function(T data) onSuccess, R Function(E error) onFailure) {
    if (this is Success<T, E>) {
      return onSuccess((this as Success<T, E>).data);
    } else {
      return onFailure((this as Failure<T, E>).error);
    }
  }

  /// Maps the success data if it's a Success, or returns the Failure as is.
  Result<R, E> map<R>(R Function(T data) mapper) {
    if (this is Success<T, E>) {
      return Success(mapper((this as Success<T, E>).data));
    } else {
      return Failure((this as Failure<T, E>).error);
    }
  }

  T? getOrNull() => this is Success<T, E> ? (this as Success<T, E>).data : null;
  E? errorOrNull() => this is Failure<T, E> ? (this as Failure<T, E>).error : null;
}

class Success<T, E extends AppException> extends Result<T, E> {
  final T data;
  const Success(this.data);
}

class Failure<T, E extends AppException> extends Result<T, E> {
  final E error;
  const Failure(this.error);
}
