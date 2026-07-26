/// Base failure representation for all domain layers.
abstract class Failure {
  const Failure({
    required this.message,
    this.code,
    this.cause,
  });

  final String message;
  final String? code;
  final Object? cause;
}

/// Generic server failure.
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.cause,
  });
}

/// Generic network connection failure.
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.cause,
  });
}

/// AI Engine processing failure.
class AiFailure extends Failure {
  const AiFailure({
    required super.message,
    super.code,
    super.cause,
  });
}
