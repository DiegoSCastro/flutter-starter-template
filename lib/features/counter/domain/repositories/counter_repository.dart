import '../../../../core/utils/result.dart';
import '../entities/counter.dart';

abstract interface class CounterRepository {
  Future<Result<Counter>> read();

  Future<Result<Counter>> save(Counter counter);
}
