import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required SignIn signIn, required SignOut signOut})
      : _signIn = signIn,
        _signOut = signOut,
        super(const AuthState.initial());

  final SignIn _signIn;
  final SignOut _signOut;

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    if (state is AuthSubmitting) return;
    emit(const AuthState.submitting());

    final result = await _signIn(username: username, password: password);
    switch (result) {
      case Ok(value: final user):
        emit(AuthState.authenticated(user));
      case Err(failure: final failure):
        emit(AuthState.failure(failure));
    }
  }

  Future<void> signOut() async {
    final result = await _signOut();
    if (result is Ok<void>) {
      emit(const AuthState.initial());
    }
  }
}
