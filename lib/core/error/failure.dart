import '../utils/result.dart' show Result;

/// Base type for domain-layer failures returned from repositories and use
/// cases. Subclass per feature; never throw these — return them via [Result].
sealed class Failure {
  const Failure(this.message);

  final String message;
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown error']);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([super.message = 'Invalid credentials']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input']);
}
