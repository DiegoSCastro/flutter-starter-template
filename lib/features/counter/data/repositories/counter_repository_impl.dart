import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/counter.dart';
import '../../domain/repositories/counter_repository.dart';
import '../datasources/counter_local_data_source.dart';

class CounterRepositoryImpl implements CounterRepository {
  const CounterRepositoryImpl(this._dataSource);

  final CounterLocalDataSource _dataSource;

  @override
  Future<Result<Counter>> read() async {
    try {
      final value = await _dataSource.read();
      return Ok(Counter(value));
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Counter>> save(Counter counter) async {
    try {
      await _dataSource.write(counter.value);
      return Ok(counter);
    } catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }
}
