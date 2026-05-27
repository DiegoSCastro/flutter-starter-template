import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../data/sync/bookmarks_sync_service.dart';
import '../../domain/entities/bookmark.dart';

part 'bookmarks_list_state.freezed.dart';

@freezed
abstract class BookmarksListState with _$BookmarksListState {
  const BookmarksListState._();

  const factory BookmarksListState({
    @Default(false) bool isLoading,
    @Default(BookmarksSyncStatus.idle) BookmarksSyncStatus syncStatus,
    @Default([]) List<Bookmark> items,
    @Default('') String query,
    Failure? failure,
  }) = _BookmarksListState;

  /// Items filtered by the active query (matches title, url, or any tag).
  List<Bookmark> get visibleItems {
    if (query.trim().isEmpty) return items;
    final needle = query.toLowerCase();
    return items
        .where((b) {
          if (b.title.toLowerCase().contains(needle)) return true;
          if (b.url.toLowerCase().contains(needle)) return true;
          return b.tags.any((t) => t.toLowerCase().contains(needle));
        })
        .toList(growable: false);
  }
}
