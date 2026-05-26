/// Base type for domain-layer failures returned from repositories and use
/// cases. Subclass per feature; never throw these — return them via [Result].
sealed class Failure {
  const Failure(this.message);

  final String message;
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown error']);
}
