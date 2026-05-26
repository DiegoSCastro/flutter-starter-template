class Bookmark {
  const Bookmark({
    required this.id,
    required this.title,
    required this.url,
    required this.description,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String url;
  final String description;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
}
