import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'bookmarks_remote_data_source.dart';

@module
abstract class BookmarksRemoteModule {
  @lazySingleton
  BookmarksRemoteDataSource provideBookmarksRemoteDataSource(Dio dio) =>
      BookmarksRemoteDataSource(dio);
}
