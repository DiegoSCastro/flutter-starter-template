import 'package:architecture/architecture.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/get_notifications_feed.dart';
import '../../domain/usecases/mark_notification_read.dart';
import 'notifications_state.dart';

part 'notifications_event.dart';

@lazySingleton
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc(this._getFeed, this._markRead)
    : super(const NotificationsState()) {
    on<NotificationsLoadRequested>(
      _onLoadRequested,
      transformer: droppable(),
    );
    on<NotificationMarkReadRequested>(
      _onMarkReadRequested,
      transformer: sequential(),
    );
  }

  final GetNotificationsFeed _getFeed;
  final MarkNotificationRead _markRead;

  Future<void> _onLoadRequested(
    NotificationsLoadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: null));
    final result = await _getFeed();
    switch (result) {
      case Ok(value: final feed):
        emit(
          state.copyWith(
            isLoading: false,
            notifications: feed.notifications,
            activities: feed.activities,
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  Future<void> _onMarkReadRequested(
    NotificationMarkReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final id = event.id;
    final hasUnreadTarget = state.notifications.any(
      (n) => n.id == id && !n.isRead,
    );
    if (!hasUnreadTarget) return;

    // Optimistically flip to read so the UI responds immediately.
    emit(state.copyWith(notifications: _withRead(id, isRead: true)));
    final result = await _markRead(id);
    if (result is Err) {
      // Roll back if the server rejected the change.
      emit(state.copyWith(notifications: _withRead(id, isRead: false)));
    }
  }

  List<AppNotification> _withRead(String id, {required bool isRead}) {
    return state.notifications
        .map((n) => n.id == id ? n.copyWith(isRead: isRead) : n)
        .toList(growable: false);
  }
}
