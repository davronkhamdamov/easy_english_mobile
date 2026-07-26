import 'package:easy_ielts/core/errors/failure.dart';

/// Sealed functional Result type for handling operations cleanly.
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(Failure failure) = FailureResult<T>;
}

/// Represents a successful computation.
final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

/// Represents a failed computation.
final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);
  final Failure failure;
}
