part of 'profile_bloc.dart';

sealed class ProfileEvent {
  const ProfileEvent();
}

final class ProfileLoaded extends ProfileEvent {
  const ProfileLoaded({this.completer});

  final Completer<void>? completer;
}

final class ProfileSignOutRequested extends ProfileEvent {
  const ProfileSignOutRequested({this.completer});

  final Completer<void>? completer;
}

final class _ProfileAuthChanged extends ProfileEvent {
  const _ProfileAuthChanged(this.authState);

  final AuthState authState;
}
