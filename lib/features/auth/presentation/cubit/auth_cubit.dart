import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/analytics/analytics_extensions.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/usecases/restore_session.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this._signIn,
    required this._signOut,
    required this._restoreSession,
    required this._analytics,
  }) : super(const AuthState.initial());

  final SignIn _signIn;
  final SignOut _signOut;
  final RestoreSession _restoreSession;
  final AnalyticsService _analytics;

  /// Called once during app bootstrap. Tries to rehydrate a persisted session;
  /// silently lands on [AuthState.initial] if there isn't one or it expired.
  Future<void> restoreSession() async {
    final result = await _restoreSession();
    switch (result) {
      case Ok(value: final user):
        unawaited(_analytics.setCurrentUser(user.id));
        emit(AuthState.authenticated(user));
      case Err():
        unawaited(_analytics.setCurrentUser(null));
        emit(const AuthState.initial());
    }
  }

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    if (state is AuthSubmitting) return;
    emit(const AuthState.submitting());

    final result = await _signIn((username: username, password: password));
    switch (result) {
      case Ok(value: final user):
        unawaited(_analytics.setCurrentUser(user.id));
        unawaited(_analytics.logLogin(method: 'password'));
        emit(AuthState.authenticated(user));
      case Err(: final failure):
        unawaited(
          _analytics.trackLoginFailed(
            errorType: failure.runtimeType.toString(),
          ),
        );
        emit(AuthState.failure(failure));
    }
  }

  Future<void> signOut() async {
    final result = await _signOut();
    if (result is Ok<void>) {
      unawaited(_analytics.trackSignOut());
      unawaited(_analytics.setCurrentUser(null));
      emit(const AuthState.initial());
    }
  }
}
