import 'package:dio/dio.dart';
import 'package:flutter_starter_template/core/network/retry_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

/// Programmable adapter: each entry in [responses] is consumed in order on
/// successive requests. A `DioException` entry simulates a transport failure;
/// a `ResponseBody` entry simulates a server response.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.responses);

  final List<Object> responses;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final next = responses[calls];
    calls++;
    if (next is DioException) throw next;
    return next as ResponseBody;
  }

  @override
  void close({bool force = false}) {}
}

DioException _connectionError() => DioException.connectionError(
  requestOptions: RequestOptions(path: '/'),
  reason: 'boom',
);

void main() {
  // Tiny delays so the exponential backoff doesn't slow the suite.
  Dio buildDio(_ScriptedAdapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    // The interceptor re-dispatches through this same Dio.
    dio.interceptors.add(
      RetryInterceptor(
        dio,
        baseDelay: const Duration(milliseconds: 1),
        maxDelay: const Duration(milliseconds: 5),
      ),
    );
    return dio;
  }

  ResponseBody ok() => ResponseBody.fromString(
    '{}',
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  group('RetryInterceptor', () {
    test(
      'retries a transient failure and resolves on eventual success',
      () async {
        final adapter = _ScriptedAdapter([_connectionError(), ok()]);
        final dio = buildDio(adapter);

        final response = await dio.get<dynamic>('/');

        expect(response.statusCode, 200);
        expect(adapter.calls, 2);
      },
    );

    test('gives up after maxRetries and rethrows', () async {
      final adapter = _ScriptedAdapter([
        _connectionError(),
        _connectionError(),
        _connectionError(),
        _connectionError(),
      ]);
      final dio = buildDio(adapter);

      await expectLater(dio.get<dynamic>('/'), throwsA(isA<DioException>()));
      // initial attempt + 3 retries.
      expect(adapter.calls, 4);
    });

    test('retries retryable status codes (503)', () async {
      final adapter = _ScriptedAdapter([
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 503,
          ),
        ),
        ok(),
      ]);
      final dio = buildDio(adapter);

      final response = await dio.get<dynamic>('/');

      expect(response.statusCode, 200);
      expect(adapter.calls, 2);
    });

    test('does not retry non-retryable client errors (404)', () async {
      final adapter = _ScriptedAdapter([
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 404,
          ),
        ),
        ok(),
      ]);
      final dio = buildDio(adapter);

      await expectLater(dio.get<dynamic>('/'), throwsA(isA<DioException>()));
      expect(adapter.calls, 1);
    });
  });
}
