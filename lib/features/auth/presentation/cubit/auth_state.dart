import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_user.dart';

/// State surface for [AuthCubit]. Pattern-match exhaustively at call sites.
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthSubmitting extends AuthState {
  const AuthSubmitting();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AuthUser user;
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.failure);
  final Failure failure;
}
