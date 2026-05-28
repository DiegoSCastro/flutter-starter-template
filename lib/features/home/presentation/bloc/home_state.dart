import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../bookmarks/domain/entities/bookmark.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default('') String username,
    @Default(0) int totalBookmarks,
    @Default(0) int recentBookmarks,
    @Default(0) int uniqueTags,
    @Default([]) List<Bookmark> recentItems,
    @Default(false) bool isLoading,
    Failure? failure,
  }) = _HomeState;
}
