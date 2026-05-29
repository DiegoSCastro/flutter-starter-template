import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_user.dart';

part 'auth_state.freezed.dart';

/// State surface for `AuthBloc`. Pattern-match exhaustively at call sites.
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.restoring() = AuthRestoring;
  const factory AuthState.submitting() = AuthSubmitting;
  const factory AuthState.authenticated(AuthUser user) = AuthAuthenticated;
  const factory AuthState.signingOut(AuthUser user) = AuthSigningOut;
  const factory AuthState.failure(Failure failure) = AuthFailure;
}
