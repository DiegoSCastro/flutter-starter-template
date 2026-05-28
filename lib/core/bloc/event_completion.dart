import 'dart:async';

extension NullableCompleterExtension<T> on Completer<T>? {
  void completeErrorIfPending(Object error, StackTrace stackTrace) {
    final completer = this;
    if (completer == null || completer.isCompleted) return;
    completer.completeError(error, stackTrace);
  }

  void completeValueIfPending(T value) {
    final completer = this;
    if (completer == null || completer.isCompleted) return;
    completer.complete(value);
  }
}

extension NullableVoidCompleterExtension on Completer<void>? {
  void completeVoidIfPending() {
    final completer = this;
    if (completer == null || completer.isCompleted) return;
    completer.complete();
  }
}
