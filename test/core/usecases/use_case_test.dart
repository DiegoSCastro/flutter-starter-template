import 'dart:async';

import 'package:flutter_starter_template/core/error/failure.dart';
import 'package:flutter_starter_template/core/usecases/use_case.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UseCase', () {
    const useCase = _TestUseCase();

    test('passes params through call and returns Ok', () async {
      final result = await useCase('abc');

      switch (result) {
        case Ok(value: final value):
          expect(value, 3);
        case Err():
          fail('Expected Ok');
      }
    });

    test('runGuarded returns Ok for async operation', () async {
      final result = await useCase.guard(() async => 42);

      expect(result, isA<Ok<int>>());
      expect((result as Ok<int>).value, 42);
    });

    test('runGuarded maps thrown Failure to Err unchanged', () async {
      const failure = ValidationFailure('Invalid value');

      final result = await useCase.guard(() => throw failure);

      expect(result, isA<Err<int>>());
      expect((result as Err<int>).failure, same(failure));
    });

    test('runGuarded maps unknown exceptions to UnknownFailure', () async {
      final result = await useCase.guard(() => throw StateError('boom'));

      expect(result, isA<Err<int>>());
      final failure = (result as Err<int>).failure;
      expect(failure, isA<UnknownFailure>());
      expect(failure.message, contains('boom'));
    });

    test('runGuarded supports custom failure mapping', () async {
      final result = await useCase.guard(
        () => throw StateError('boom'),
        mapFailure: (_, _) => const ValidationFailure('Mapped'),
      );

      expect(result, isA<Err<int>>());
      final failure = (result as Err<int>).failure;
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Mapped');
    });
  });

  group('NoParams', () {
    test('provides a reusable no-argument marker', () {
      expect(noParams, isA<NoParams>());
    });
  });
}

class _TestUseCase extends UseCase<String, int> {
  const _TestUseCase();

  @override
  Future<Result<int>> call(String param) {
    return runGuarded(() => param.length);
  }

  Future<Result<int>> guard(
    FutureOr<int> Function() operation, {
    FailureMapper? mapFailure,
  }) {
    return runGuarded(operation, mapFailure: mapFailure);
  }
}
