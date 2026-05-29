part of 'bookmark_detail_bloc.dart';

sealed class BookmarkDetailEvent {
  const BookmarkDetailEvent();
}

final class BookmarkDetailLoadRequested extends BookmarkDetailEvent {
  const BookmarkDetailLoadRequested(this.id, {this.completer});

  final String id;
  final Completer<void>? completer;
}

final class BookmarkDetailDeleteRequested extends BookmarkDetailEvent {
  const BookmarkDetailDeleteRequested(this.id, {this.completer});

  final String id;
  final Completer<bool>? completer;
}
