class Bookmark {
  const Bookmark({
    required this.id,
    required this.title,
    required this.url,
    required this.description,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrls = const [],
    this.videoUrl,
    this.isPendingSync = false,
  });

  final String id;
  final String title;
  final String url;
  final String description;
  final List<String> tags;
  final List<String> imageUrls;
  final String? videoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// `true` when this bookmark has local changes that haven't been pushed
  /// to the server yet. UI surfaces a badge for these.
  final bool isPendingSync;
}

class BookmarkInput {
  const BookmarkInput({
    required this.title,
    required this.url,
    required this.description,
    required this.tags,
    this.imageUrls = const [],
    this.videoUrl,
  });

  final String title;
  final String url;
  final String description;
  final List<String> tags;
  final List<String> imageUrls;
  final String? videoUrl;
}
