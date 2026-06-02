import 'package:core_domain/core_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/domain/bookmark_stats.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(0) int totalBookmarks,
    @Default(0) int recentBookmarks,
    @Default(0) int uniqueTags,
    @Default([]) List<BookmarkSummary> recentItems,
    @Default(false) bool isLoading,
    Failure? failure,
  }) = _HomeState;
}
