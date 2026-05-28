enum BookmarksSyncStatus { idle, syncing, error }

abstract interface class BookmarksSyncController {
  Stream<BookmarksSyncStatus> get statusStream;
  BookmarksSyncStatus get statusNow;

  Future<void> start();
  Future<void> stop();
  Future<void> sync();
}
