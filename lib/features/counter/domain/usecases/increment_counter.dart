import '../../../../core/utils/result.dart';
import '../entities/counter.dart';
import '../repositories/counter_repository.dart';

class IncrementCounter {
  const IncrementCounter(this._repository);

  final CounterRepository _repository;

  Future<Result<Counter>> call() async {
    final current = await _repository.read();
    return switch (current) {
      Ok(value: final counter) => _repository.save(counter.incremented()),
      Err() => current,
    };
  }
}
