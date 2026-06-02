import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core_network/core_network.dart';
import 'package:flutter_starter_template/features/bookmarks/data/datasources/bookmarks_remote_data_source.dart';
import 'package:flutter_starter_template/features/bookmarks/data/local/bookmark_entity.dart';
import 'package:flutter_starter_template/features/bookmarks/data/local/bookmarks_local_data_source.dart';
import 'package:flutter_starter_template/features/bookmarks/data/models/bookmark_dto.dart';
import 'package:flutter_starter_template/features/bookmarks/data/models/bookmark_request.dart';
import 'package:flutter_starter_template/features/bookmarks/data/sync/bookmarks_sync_service.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/services/bookmarks_sync_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

class MockBookmarksLocalDataSource extends Mock
    implements BookmarksLocalDataSource {}

class MockBookmarksRemoteDataSource extends Mock
    implements BookmarksRemoteDataSource {}

class MockConnectivity extends Mock implements Connectivity {}

class FakeBookmarkEntity extends Fake implements BookmarkEntity {}

class FakeBookmarkRequest extends Fake implements BookmarkRequest {}

class FakeMultipartFile extends Fake implements MultipartFile {}

BookmarkEntity createEntity({
  int id = 1,
  String uuid = 'b-1',
  String title = 'Flutter',
  String url = 'https://flutter.dev',
  String description = 'desc',
  List<String> tags = const ['dev'],
  DateTime? createdAt,
  DateTime? updatedAt,
  int syncStateCode = 0,
}) {
  final now = DateTime(2025, 1, 1);
  return BookmarkEntity(
    id: id,
    uuid: uuid,
    title: title,
    url: url,
    description: description,
    tags: tags,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
    syncStateCode: syncStateCode,
  );
}

BookmarkDto createDto({
  required String id,
  String title = 'Flutter',
  String url = 'https://flutter.dev',
  String description = 'desc',
  List<String> tags = const ['dev'],
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return BookmarkDto(
    id: id,
    title: title,
    url: url,
    description: description,
    tags: tags,
    createdAt: createdAt ?? DateTime(2025, 1, 1),
    updatedAt: updatedAt ?? DateTime(2025, 1, 1),
  );
}

void main() {
  late MockBookmarksLocalDataSource mockLocal;
  late MockBookmarksRemoteDataSource mockRemote;
  late MockConnectivity mockConnectivity;
  late BookmarksSyncService service;
  late StreamController<List<ConnectivityResult>> connectivityController;

  setUpAll(() {
    registerFallbackValue(FakeBookmarkEntity());
    registerFallbackValue(FakeBookmarkRequest());
    registerFallbackValue(FakeMultipartFile());
  });

  setUp(() {
    mockLocal = MockBookmarksLocalDataSource();
    mockRemote = MockBookmarksRemoteDataSource();
    mockConnectivity = MockConnectivity();
    connectivityController =
        StreamController<List<ConnectivityResult>>.broadcast();

    when(
      () => mockConnectivity.onConnectivityChanged,
    ).thenAnswer((_) => connectivityController.stream);
    when(
      () => mockConnectivity.checkConnectivity(),
    ).thenAnswer((_) async => [ConnectivityResult.wifi]);

    service = BookmarksSyncService(mockLocal, mockRemote, mockConnectivity);
  });

  tearDown(() async {
    await connectivityController.close();
    await service.stop();
  });

  group('initial state', () {
    test('status is idle before any sync', () {
      expect(service.statusNow, BookmarksSyncStatus.idle);
    });
  });

  group('sync status transitions', () {
    test('ends idle after successful sync', () async {
      when(() => mockLocal.listPending()).thenAnswer((_) async => []);
      when(() => mockLocal.listAll()).thenAnswer((_) async => []);
      when(() => mockRemote.list()).thenAnswer((_) async => []);

      await service.sync();

      expect(service.statusNow, BookmarksSyncStatus.idle);
    });
  });

  group('_push pendingCreate', () {
    test('posts create to server and marks synced', () async {
      when(() => mockLocal.listAll()).thenAnswer((_) async => []);
      when(() => mockRemote.list()).thenAnswer((_) async => []);

      final entity = createEntity(syncStateCode: 1); // pendingCreate
      when(() => mockLocal.listPending()).thenAnswer((_) async => [entity]);
      when(() => mockRemote.create(any())).thenAnswer(
        (_) async => createDto(id: 'b-1', updatedAt: DateTime(2025, 2, 1)),
      );
      when(() => mockLocal.put(any())).thenAnswer((_) async {});

      await service.sync();

      verify(() => mockRemote.create(any())).called(1);
      expect(entity.syncState, SyncState.synced);
      expect(entity.serverUpdatedAt, DateTime(2025, 2, 1));
      verify(() => mockLocal.put(entity)).called(1);
    });
  });

  group('_push pendingUpdate', () {
    test('puts update to server and marks synced', () async {
      when(() => mockLocal.listAll()).thenAnswer((_) async => []);
      when(() => mockRemote.list()).thenAnswer((_) async => []);

      final entity = createEntity(syncStateCode: 2); // pendingUpdate
      when(() => mockLocal.listPending()).thenAnswer((_) async => [entity]);
      when(() => mockRemote.update(any(), any())).thenAnswer(
        (_) async => createDto(id: 'b-1', updatedAt: DateTime(2025, 3, 1)),
      );
      when(() => mockLocal.put(any())).thenAnswer((_) async {});

      await service.sync();

      verify(() => mockRemote.update('b-1', any())).called(1);
      expect(entity.syncState, SyncState.synced);
      expect(entity.serverUpdatedAt, DateTime(2025, 3, 1));
      verify(() => mockLocal.put(entity)).called(1);
    });
  });

  group('_push pendingDelete', () {
    test('deletes on server and hard deletes locally', () async {
      when(() => mockLocal.listAll()).thenAnswer((_) async => []);
      when(() => mockRemote.list()).thenAnswer((_) async => []);

      final entity = createEntity(id: 42, syncStateCode: 3);
      when(() => mockLocal.listPending()).thenAnswer((_) async => [entity]);
      when(() => mockRemote.delete('b-1')).thenAnswer((_) async {});
      when(() => mockLocal.hardDelete(42)).thenAnswer((_) async {});

      await service.sync();

      verify(() => mockRemote.delete('b-1')).called(1);
      verify(() => mockLocal.hardDelete(42)).called(1);
    });

    test('swallows 404 and still hard deletes', () async {
      when(() => mockLocal.listAll()).thenAnswer((_) async => []);
      when(() => mockRemote.list()).thenAnswer((_) async => []);

      final entity = createEntity(id: 42, syncStateCode: 3);
      when(() => mockLocal.listPending()).thenAnswer((_) async => [entity]);
      when(() => mockRemote.delete('b-1')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/bookmarks/b-1'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/bookmarks/b-1'),
            statusCode: 404,
          ),
        ),
      );
      when(() => mockLocal.hardDelete(42)).thenAnswer((_) async {});

      await service.sync();

      verify(() => mockLocal.hardDelete(42)).called(1);
    });

    test(
      'keeps row pending and sets error status on non-404 failure',
      () async {
        when(() => mockLocal.listAll()).thenAnswer((_) async => []);
        when(() => mockRemote.list()).thenAnswer((_) async => []);
        final entity = createEntity(id: 42, syncStateCode: 3);
        when(() => mockLocal.listPending()).thenAnswer((_) async => [entity]);
        when(() => mockRemote.delete('b-1')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/bookmarks/b-1'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/bookmarks/b-1'),
              statusCode: 500,
            ),
          ),
        );

        await service.sync();

        expect(service.statusNow, BookmarksSyncStatus.error);
        verifyNever(() => mockLocal.hardDelete(42));
      },
    );
  });

  group('per-row failure isolation', () {
    test('one failing row does not block the rest of the queue', () async {
      when(() => mockLocal.listAll()).thenAnswer((_) async => []);
      when(() => mockRemote.list()).thenAnswer((_) async => []);
      when(() => mockLocal.put(any())).thenAnswer((_) async {});

      final poison = createEntity(uuid: 'poison', syncStateCode: 1);
      final good = createEntity(uuid: 'good', syncStateCode: 1);
      when(
        () => mockLocal.listPending(),
      ).thenAnswer((_) async => [poison, good]);

      when(() => mockRemote.create(any())).thenAnswer((invocation) async {
        final req = invocation.positionalArguments.first as BookmarkRequest;
        if (req.id == 'poison') {
          throw DioException(
            requestOptions: RequestOptions(path: '/api/bookmarks'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/bookmarks'),
              statusCode: 400,
            ),
          );
        }
        return createDto(id: req.id!, updatedAt: DateTime(2025, 2, 1));
      });

      await service.sync();

      // The good row was still pushed and marked synced despite the poison row.
      verify(() => mockRemote.create(any())).called(2);
      expect(good.syncState, SyncState.synced);
      expect(poison.syncState, SyncState.pendingCreate);
      // A failed row still surfaces as a non-clean sync.
      expect(service.statusNow, BookmarksSyncStatus.error);
    });

    test('treats a 409 on create as already-created (marks synced)', () async {
      when(() => mockLocal.listAll()).thenAnswer((_) async => []);
      when(() => mockRemote.list()).thenAnswer((_) async => []);
      when(() => mockLocal.put(any())).thenAnswer((_) async {});

      final entity = createEntity(uuid: 'dup', syncStateCode: 1);
      when(() => mockLocal.listPending()).thenAnswer((_) async => [entity]);
      when(() => mockRemote.create(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/bookmarks'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/bookmarks'),
            statusCode: 409,
          ),
        ),
      );

      await service.sync();

      expect(entity.syncState, SyncState.synced);
      verify(() => mockLocal.put(entity)).called(1);
    });
  });

  group('media upload checkpoint', () {
    test(
      'persists uploaded URLs before create and never re-uploads on retry',
      () async {
        when(() => mockLocal.listAll()).thenAnswer((_) async => []);
        when(() => mockRemote.list()).thenAnswer((_) async => []);
        when(() => mockLocal.put(any())).thenAnswer((_) async {});

        final tempDir = await Directory.systemTemp.createTemp('sync_test');
        addTearDown(() => tempDir.delete(recursive: true));
        final file = File('${tempDir.path}/a.jpg')..writeAsBytesSync([1, 2, 3]);

        final entity = createEntity(uuid: 'with-media', syncStateCode: 1)
          ..imageUrls = [file.path];
        when(() => mockLocal.listPending()).thenAnswer((_) async => [entity]);

        when(
          () => mockRemote.upload(any()),
        ).thenAnswer((_) async => {'url': 'https://srv/a.jpg'});
        // The create always fails, so the row stays pendingCreate across syncs.
        when(() => mockRemote.create(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/bookmarks'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/bookmarks'),
              statusCode: 500,
            ),
          ),
        );

        await service.sync();

        // The local file path was swapped for the uploaded remote URL and
        // checkpointed before the failing create.
        expect(entity.imageUrls, ['https://srv/a.jpg']);
        expect(entity.syncState, SyncState.pendingCreate);

        // Second sync of the same (now http-only) row must not re-upload.
        await service.sync();

        // Exactly one upload across both syncs — no duplicate/orphaned blob.
        verify(() => mockRemote.upload(any())).called(1);
      },
    );
  });

  group('_pull insert', () {
    test('inserts server-only bookmark as synced', () async {
      when(() => mockLocal.listPending()).thenAnswer((_) async => []);
      when(() => mockLocal.listAll()).thenAnswer((_) async => []);
      final dto = createDto(id: 'srv-1', title: 'Server Only');
      when(() => mockRemote.list()).thenAnswer((_) async => [dto]);
      when(() => mockLocal.put(any())).thenAnswer((_) async {});

      await service.sync();

      final captured = verify(() => mockLocal.put(captureAny())).captured;
      expect(captured.length, 1);
      final entity = captured.single as BookmarkEntity;
      expect(entity.uuid, 'srv-1');
      expect(entity.title, 'Server Only');
      expect(entity.syncState, SyncState.synced);
    });
  });

  group('_pull last-write-wins', () {
    test('skips pending rows (does not clobber user changes)', () async {
      when(() => mockLocal.listPending()).thenAnswer((_) async => []);
      final local = createEntity(
        uuid: 'b-1',
        title: 'Local Edit',
        updatedAt: DateTime(2025, 1, 5),
        syncStateCode: 1, // pendingCreate
      );
      final dto = createDto(
        id: 'b-1',
        title: 'Server Version',
        updatedAt: DateTime(2025, 1, 10),
      );
      when(() => mockLocal.listAll()).thenAnswer((_) async => [local]);
      when(() => mockRemote.list()).thenAnswer((_) async => [dto]);

      await service.sync();

      verifyNever(() => mockLocal.put(any()));
    });

    test('takes server version when strictly newer', () async {
      when(() => mockLocal.listPending()).thenAnswer((_) async => []);
      final local = createEntity(
        uuid: 'b-1',
        title: 'Old Local',
        updatedAt: DateTime(2025, 1, 5),
      );
      final dto = createDto(
        id: 'b-1',
        title: 'New Server',
        updatedAt: DateTime(2025, 1, 10),
      );
      when(() => mockLocal.listAll()).thenAnswer((_) async => [local]);
      when(() => mockRemote.list()).thenAnswer((_) async => [dto]);
      when(() => mockLocal.put(any())).thenAnswer((_) async {});

      await service.sync();

      expect(local.title, 'New Server');
      verify(() => mockLocal.put(local)).called(1);
    });

    test('keeps local version when server is older', () async {
      when(() => mockLocal.listPending()).thenAnswer((_) async => []);
      final local = createEntity(
        uuid: 'b-1',
        title: 'Newer Local',
        updatedAt: DateTime(2025, 1, 10),
      );
      final dto = createDto(
        id: 'b-1',
        title: 'Old Server',
        updatedAt: DateTime(2025, 1, 5),
      );
      when(() => mockLocal.listAll()).thenAnswer((_) async => [local]);
      when(() => mockRemote.list()).thenAnswer((_) async => [dto]);

      await service.sync();

      verifyNever(() => mockLocal.put(local));
    });
  });

  group('_pull server-side delete', () {
    test('hard deletes synced local rows missing from server', () async {
      when(() => mockLocal.listPending()).thenAnswer((_) async => []);
      final local = createEntity(id: 42);
      when(() => mockLocal.listAll()).thenAnswer((_) async => [local]);
      when(() => mockRemote.list()).thenAnswer((_) async => []);
      when(() => mockLocal.hardDelete(42)).thenAnswer((_) async {});

      await service.sync();

      verify(() => mockLocal.hardDelete(42)).called(1);
    });

    test('keeps pendingCreate rows missing from server', () async {
      when(() => mockLocal.listPending()).thenAnswer((_) async => []);
      final local = createEntity(id: 42, syncStateCode: 1);
      when(() => mockLocal.listAll()).thenAnswer((_) async => [local]);
      when(() => mockRemote.list()).thenAnswer((_) async => []);

      await service.sync();

      verifyNever(() => mockLocal.hardDelete(any()));
    });
  });

  group('error handling', () {
    test('emits error on DioException', () async {
      when(() => mockLocal.listPending()).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/api/bookmarks')),
      );

      await service.sync();

      expect(service.statusNow, BookmarksSyncStatus.error);
    });

    test('emits error on generic exception', () async {
      when(() => mockLocal.listPending()).thenThrow(Exception('boom'));

      await service.sync();

      expect(service.statusNow, BookmarksSyncStatus.error);
    });
  });

  group('single-flight sync', () {
    test('concurrent sync calls share one in-flight', () async {
      final completer = Completer<List<BookmarkEntity>>();
      when(() => mockLocal.listPending()).thenAnswer((_) => completer.future);
      when(() => mockLocal.listAll()).thenAnswer(
        (_) => Future<List<BookmarkEntity>>.delayed(Duration.zero, () => []),
      );
      when(() => mockRemote.list()).thenAnswer(
        (_) => Future<List<BookmarkDto>>.delayed(Duration.zero, () => []),
      );

      final f1 = service.sync();
      final f2 = service.sync();

      expect(f1, same(f2));

      completer.complete([]);
      await f1;

      verify(() => mockLocal.listPending()).called(1);
    });
  });

  group('connectivity handling', () {
    test('triggers sync when coming back online from offline', () async {
      when(() => mockLocal.listPending()).thenAnswer((_) async => []);
      when(() => mockLocal.listAll()).thenAnswer((_) async => []);
      when(() => mockRemote.list()).thenAnswer((_) async => []);

      await service.start();
      // Wait for the initial unawaited sync to complete
      await Future<void>.delayed(Duration.zero);

      when(() => mockLocal.listPending()).thenAnswer((_) async => []);
      when(() => mockLocal.listAll()).thenAnswer((_) async => []);
      when(() => mockRemote.list()).thenAnswer((_) async => []);

      connectivityController.add([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);
      connectivityController.add([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);

      // listPending called at least twice (initial + reconnect)
      verify(() => mockLocal.listPending()).called(greaterThanOrEqualTo(2));
    });

    test('does not trigger sync when staying online', () async {
      when(() => mockLocal.listPending()).thenAnswer((_) async => []);
      when(() => mockLocal.listAll()).thenAnswer((_) async => []);
      when(() => mockRemote.list()).thenAnswer((_) async => []);

      await service.start();
      await Future<void>.delayed(Duration.zero);

      when(() => mockLocal.listPending()).thenAnswer((_) async => []);

      connectivityController.add([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);

      // Only called from the initial start — not from connectivity
      verify(() => mockLocal.listPending()).called(1);
    });
  });
}
