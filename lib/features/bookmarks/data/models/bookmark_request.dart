import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark_request.freezed.dart';
part 'bookmark_request.g.dart';

/// Wire payload used for both create (POST) and update (PUT) — the backend
/// treats them as a full replacement.
@Freezed(copyWith: false, equal: false)
abstract class BookmarkRequest with _$BookmarkRequest {
  const factory BookmarkRequest({
    required String title,
    required String url,
    required String description,
    required List<String> tags,
  }) = _BookmarkRequest;

  factory BookmarkRequest.fromJson(Map<String, dynamic> json) =>
      _$BookmarkRequestFromJson(json);
}
