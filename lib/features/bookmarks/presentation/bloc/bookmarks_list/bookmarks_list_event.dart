part of 'bookmarks_list_bloc.dart';

sealed class BookmarksListEvent {
  const BookmarksListEvent();
}

final class BookmarksListLoadRequested extends BookmarksListEvent {
  const BookmarksListLoadRequested({this.completer});

  final Completer<void>? completer;
}

final class BookmarksListQueryChanged extends BookmarksListEvent {
  const BookmarksListQueryChanged(this.query, {this.completer});

  final String query;
  final Completer<void>? completer;
}

final class BookmarksListDeleteRequested extends BookmarksListEvent {
  const BookmarksListDeleteRequested(this.id, {this.completer});

  final String id;
  final Completer<void>? completer;
}

final class BookmarksListSyncRetried extends BookmarksListEvent {
  const BookmarksListSyncRetried({this.completer});

  final Completer<void>? completer;
}

final class _BookmarksSyncStatusChanged extends BookmarksListEvent {
  const _BookmarksSyncStatusChanged(this.status);

  final BookmarksSyncStatus status;
}

final class _BookmarksReloadSilentlyRequested extends BookmarksListEvent {
  const _BookmarksReloadSilentlyRequested();
}
