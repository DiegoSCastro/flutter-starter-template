import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/analytics/analytics_extensions.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/bloc/event_completion.dart';
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
  bool _signInInFlight = false;
  bool _registerInFlight = false;

  /// Called once during app bootstrap. Tries to rehydrate a persisted session;
  /// silently lands on [AuthState.initial] if there isn't one or it expired.
  Future<void> restoreSession() {
    final completer = Completer<void>();
    add(AuthSessionRestoreRequested(completer: completer));
    return completer.future;
  }

  Future<void> signIn({
    required String username,
    required String password,
  }) {
    if (state is AuthSubmitting || _signInInFlight) return Future<void>.value();
    _signInInFlight = true;
    final completer = Completer<void>();
    add(
      AuthSignInRequested(
        username: username,
        password: password,
        completer: completer,
      ),
    );
    return completer.future.whenComplete(() => _signInInFlight = false);
  }

  Future<void> register({
    required String username,
    required String password,
  }) {
    if (state is AuthSubmitting || _registerInFlight) {
      return Future<void>.value();
    }
    _registerInFlight = true;
    final completer = Completer<void>();
    add(
      AuthRegisterRequested(
        username: username,
        password: password,
        completer: completer,
      ),
    );
    return completer.future.whenComplete(() => _registerInFlight = false);
  }

  Future<void> signOut() {
    final completer = Completer<void>();
    add(AuthSignOutRequested(completer: completer));
    return completer.future;
  }

  Future<void> _onSessionRestoreRequested(
    AuthSessionRestoreRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await _restoreSession();
      switch (result) {
        case Ok(value: final user):
          unawaited(_analytics.setCurrentUser(user.id));
          emit(AuthState.authenticated(user));
        case Err():
          unawaited(_analytics.setCurrentUser(null));
          emit(const AuthState.initial());
      }
      event.completer.completeVoidIfPending();
    } catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
      rethrow;
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      if (state is AuthSubmitting) {
        event.completer.completeVoidIfPending();
        return;
      }
      emit(const AuthState.submitting());

      final result = await _signIn((
        username: event.username,
        password: event.password,
      ));
      switch (result) {
        case Ok(value: final user):
          unawaited(_analytics.setCurrentUser(user.id));
          unawaited(_analytics.logLogin(method: 'password'));
          emit(AuthState.authenticated(user));
        case Err(:final failure):
          unawaited(
            _analytics.trackLoginFailed(
              errorType: failure.runtimeType.toString(),
            ),
          );
          emit(AuthState.failure(failure));
      }
      event.completer.completeVoidIfPending();
    } catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
      rethrow;
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      if (state is AuthSubmitting) {
        event.completer.completeVoidIfPending();
        return;
      }
      emit(const AuthState.submitting());

      final result = await _register((
        username: event.username,
        password: event.password,
      ));
      switch (result) {
        case Ok(value: final user):
          unawaited(_analytics.setCurrentUser(user.id));
          unawaited(_analytics.logSignUp(signUpMethod: 'password'));
          emit(AuthState.authenticated(user));
        case Err(:final failure):
          unawaited(
            _analytics.trackLoginFailed(
              errorType: failure.runtimeType.toString(),
            ),
          );
          emit(AuthState.failure(failure));
      }
      event.completer.completeVoidIfPending();
    } catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
      rethrow;
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await _signOut();
      if (result is Ok<void>) {
        unawaited(_analytics.trackSignOut());
        unawaited(_analytics.setCurrentUser(null));
        emit(const AuthState.initial());
      }
      event.completer.completeVoidIfPending();
    } catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
      rethrow;
    }
  }
}
