part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class AuthSessionRestoreRequested extends AuthEvent {
  const AuthSessionRestoreRequested({this.completer});

  final Completer<void>? completer;
}

final class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({
    required this.username,
    required this.password,
    this.completer,
  });

  final String username;
  final String password;
  final Completer<void>? completer;
}

final class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.username,
    required this.password,
    this.completer,
  });

  final String username;
  final String password;
  final Completer<void>? completer;
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested({this.completer});

  final Completer<void>? completer;
}
