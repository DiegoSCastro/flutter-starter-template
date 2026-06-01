import 'dart:async';

import '../../../../../core/analytics/analytics_service.dart';
import '../../../../../core/future_extensions.dart';

class BookmarksSearchAnalyticsTracker {
  BookmarksSearchAnalyticsTracker(this._analytics);

  static const _debounce = Duration(milliseconds: 350);

  final AnalyticsService _analytics;
  Timer? _timer;

  void schedule({required String query, required int resultCount}) {
    final normalized = query.trim();
    _timer?.cancel();
    if (normalized.isEmpty) return;
    _timer = Timer(_debounce, () {
      _analytics
          .trackBookmarkSearch(
            queryLength: normalized.length,
            resultCount: resultCount,
          )
          .uw();
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}
