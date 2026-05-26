import 'package:flutter/foundation.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/counter.dart';
import '../../domain/repositories/counter_repository.dart';
import '../../domain/usecases/increment_counter.dart';

class CounterViewModel extends ChangeNotifier {
  CounterViewModel({
    required CounterRepository repository,
    required IncrementCounter increment,
  })  : _repository = repository, // ignore: prefer_initializing_formals
        _increment = increment; // ignore: prefer_initializing_formals

  final CounterRepository _repository;
  final IncrementCounter _increment;

  Counter _counter = const Counter(0);
  Counter get counter => _counter;

  Future<void> load() async {
    final result = await _repository.read();
    if (result case Ok(value: final c)) {
      _counter = c;
      notifyListeners();
    }
  }

  Future<void> increment() async {
    final result = await _increment();
    if (result case Ok(value: final c)) {
      _counter = c;
      notifyListeners();
    }
  }
}
