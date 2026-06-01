import '../../core/usecases/use_case.dart';

/// Lightweight projection of a bookmark for cross-feature display (e.g. the
/// home dashboard), so consumers don't depend on the bookmarks feature's
/// `Bookmark` aggregate.
class BookmarkSummary {
  const BookmarkSummary({
    required this.id,
    required this.title,
    required this.url,
    required this.description,
    required this.tags,
  });

  final String id;
  final String title;
  final String url;
  final String description;
  final List<String> tags;
}

/// Aggregate bookmark figures plus the most recent entries, shared by features
/// that summarize bookmarks without owning the bookmark domain.
class BookmarkStats {
  const BookmarkStats({
    this.total = 0,
    this.recent = 0,
    this.uniqueTags = 0,
    this.recentItems = const [],
  });

  final int total;
  final int recent;
  final int uniqueTags;
  final List<BookmarkSummary> recentItems;
}

/// Reads bookmark statistics. Implemented by the bookmarks feature (which owns
/// the data and the "recent" rule) and consumed through `shared`.
abstract class BookmarkStatsReader extends NoParamUseCase<BookmarkStats> {
  const BookmarkStatsReader();
}
