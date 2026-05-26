abstract interface class CounterLocalDataSource {
  Future<int> read();

  Future<void> write(int value);
}

class InMemoryCounterDataSource implements CounterLocalDataSource {
  int _value = 0;

  @override
  Future<int> read() async => _value;

  @override
  Future<void> write(int value) async {
    _value = value;
  }
}
