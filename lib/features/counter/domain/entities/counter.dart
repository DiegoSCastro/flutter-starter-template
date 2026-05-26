import 'package:flutter/foundation.dart';

@immutable
class Counter {
  const Counter(this.value);

  final int value;

  Counter incremented() => Counter(value + 1);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Counter && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
