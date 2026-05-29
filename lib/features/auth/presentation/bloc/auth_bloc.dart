import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/analytics/analytics_extensions.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/future_extensions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/restore_session.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import 'auth_state.dart';

part 'auth_event.dart';

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._signIn,
    required this._register,
    required this._signOut,
    required this._restoreSession,
    required this._analytics,
  }) : super(const AuthState.initial()) {
    on<AuthSessionRestoreRequested>(
      _onSessionRestoreRequested,
      transformer: sequential(),
    );
    on<AuthSignInRequested>(_onSignInRequested, transformer: sequential());
    on<AuthRegisterRequested>(_onRegisterRequested, transformer: sequential());
    on<AuthSignOutRequested>(_onSignOutRequested, transformer: sequential());
  }

  final SignIn _signIn;
  final Register _register;
  final SignOut _signOut;
  final RestoreSession _restoreSession;
  final AnalyticsService _analytics;
  bool _credentialsRequestInFlight = false;
  bool _signOutInFlight = false;

  Future<void> _onSessionRestoreRequested(
    AuthSessionRestoreRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthState.submitting());
      final result = await _restoreSession();
      switch (result) {
        case Ok(value: final user):
          _analytics.setCurrentUser(user.id).uw();
          emit(AuthState.authenticated(user));
        case Err():
          _analytics.setCurrentUser(null).uw();
          emit(const AuthState.initial());
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_credentialsRequestInFlight) return;
    _credentialsRequestInFlight = true;
    try {
      if (state is AuthSubmitting) {
        return;
      }
      emit(const AuthState.submitting());

      final result = await _signIn((
        username: event.username,
        password: event.password,
      ));
      switch (result) {
        case Ok(value: final user):
          _analytics.setCurrentUser(user.id).uw();
          _analytics.logLogin(method: 'password').uw();
          emit(AuthState.authenticated(user));
        case Err(:final failure):
          _analytics
              .trackLoginFailed(errorType: failure.runtimeType.toString())
              .uw();
          emit(AuthState.failure(failure));
      }
    } catch (_) {
      rethrow;
    } finally {
      _credentialsRequestInFlight = false;
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_credentialsRequestInFlight) return;
    _credentialsRequestInFlight = true;
    try {
      if (state is AuthSubmitting) {
        return;
      }
      emit(const AuthState.submitting());

      final result = await _register((
        username: event.username,
        password: event.password,
      ));
      switch (result) {
        case Ok(value: final user):
          _analytics.setCurrentUser(user.id).uw();
          _analytics.logSignUp(signUpMethod: 'password').uw();
          emit(AuthState.authenticated(user));
        case Err(:final failure):
          _analytics
              .trackLoginFailed(errorType: failure.runtimeType.toString())
              .uw();
          emit(AuthState.failure(failure));
      }
    } catch (_) {
      rethrow;
    } finally {
      _credentialsRequestInFlight = false;
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_signOutInFlight) return;
    _signOutInFlight = true;
    try {
      final result = await _signOut();
      switch (result) {
        case Ok<void>():
          _analytics.trackSignOut().uw();
          _analytics.setCurrentUser(null).uw();
          emit(const AuthState.initial());
        case Err():
          _analytics.setCurrentUser(null).uw();
          emit(const AuthState.initial());
      }
    } catch (_) {
      rethrow;
    } finally {
      _signOutInFlight = false;
    }
  }
}
