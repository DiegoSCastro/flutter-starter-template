part of 'home_bloc.dart';

sealed class HomeEvent {
  const HomeEvent();
}

final class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested({this.completer});

  final Completer<void>? completer;
}
