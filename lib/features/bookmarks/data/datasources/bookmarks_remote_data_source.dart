import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/bookmark_dto.dart';
import '../models/bookmark_request.dart';

part 'bookmarks_remote_data_source.g.dart';

@RestApi()
abstract class BookmarksRemoteDataSource {
  factory BookmarksRemoteDataSource(Dio dio, {String baseUrl}) =
      _BookmarksRemoteDataSource;

  @GET('/api/bookmarks')
  Future<List<BookmarkDto>> list();

  @GET('/api/bookmarks/{id}')
  Future<BookmarkDto> get(@Path('id') String id);

  @POST('/api/bookmarks')
  Future<BookmarkDto> create(@Body() BookmarkRequest body);

  @PUT('/api/bookmarks/{id}')
  Future<BookmarkDto> update(@Path('id') String id, @Body() BookmarkRequest body);

  @DELETE('/api/bookmarks/{id}')
  Future<void> delete(@Path('id') String id);
}
