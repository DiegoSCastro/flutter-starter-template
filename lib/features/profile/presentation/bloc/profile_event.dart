part of 'profile_bloc.dart';

sealed class ProfileEvent {
  const ProfileEvent();
}

final class ProfileLoaded extends ProfileEvent {
  const ProfileLoaded(this.user);

  final AuthUser? user;
}

final class ProfileSignOutRequested extends ProfileEvent {
  const ProfileSignOutRequested();
}
