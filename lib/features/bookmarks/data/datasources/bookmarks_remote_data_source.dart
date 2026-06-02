import 'package:core_network/core_network.dart';

import '../models/bookmark_dto.dart';
import '../models/bookmark_request.dart';

part 'bookmarks_remote_data_source.g.dart';

@RestApi()
abstract class BookmarksRemoteDataSource {
  factory BookmarksRemoteDataSource(Dio dio, {String baseUrl}) =
      _BookmarksRemoteDataSource;

  @GET('/api/bookmarks')
  Future<List<BookmarkDto>> list();

  @POST('/api/bookmarks')
  Future<BookmarkDto> create(@Body() BookmarkRequest body);

  @PUT('/api/bookmarks/{id}')
  Future<BookmarkDto> update(
    @Path('id') String id,
    @Body() BookmarkRequest body,
  );

  @DELETE('/api/bookmarks/{id}')
  Future<void> delete(@Path('id') String id);

  @POST('/api/upload')
  @MultiPart()
  Future<Map<String, String>> upload(@Part(name: 'file') MultipartFile file);
}
