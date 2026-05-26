import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/repositories/bookmarks_repository.dart';
import '../datasources/bookmarks_remote_data_source.dart';
import '../models/bookmark_request.dart';

@LazySingleton(as: BookmarksRepository)
class BookmarksRepositoryImpl implements BookmarksRepository {
  BookmarksRepositoryImpl(this._remote);

  final BookmarksRemoteDataSource _remote;

  @override
  Future<Result<List<Bookmark>>> list() async {
    try {
      final dtos = await _remote.list();
      return Ok(dtos.map((d) => d.toDomain()).toList(growable: false));
    } on DioException catch (e) {
      return Err(_map(e));
    }
  }

  @override
  Future<Result<Bookmark>> get(String id) async {
    try {
      final dto = await _remote.get(id);
      return Ok(dto.toDomain());
    } on DioException catch (e) {
      return Err(_map(e));
    }
  }

  @override
  Future<Result<Bookmark>> create(BookmarkInput input) async {
    try {
      final dto = await _remote.create(_toRequest(input));
      return Ok(dto.toDomain());
    } on DioException catch (e) {
      return Err(_map(e));
    }
  }

  @override
  Future<Result<Bookmark>> update(String id, BookmarkInput input) async {
    try {
      final dto = await _remote.update(id, _toRequest(input));
      return Ok(dto.toDomain());
    } on DioException catch (e) {
      return Err(_map(e));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _remote.delete(id);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(_map(e));
    }
  }

  BookmarkRequest _toRequest(BookmarkInput input) => BookmarkRequest(
        title: input.title,
        url: input.url,
        description: input.description,
        tags: input.tags,
      );

  Failure _map(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return ValidationFailure(_extractMessage(e.response?.data) ?? 'Invalid input.');
      case 404:
        return const NotFoundFailure('Bookmark not found.');
      default:
        return UnknownFailure(e.message ?? 'Network error');
    }
  }

  String? _extractMessage(Object? body) {
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String) return message;
    }
    return null;
  }
}
