import 'dart:async';

extension UnawaitedFutureExtension<T> on Future<T> {
  void uw() => unawaited(this);
}
