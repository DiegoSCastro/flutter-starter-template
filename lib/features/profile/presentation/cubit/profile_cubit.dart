import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import 'profile_state.dart';

@lazySingleton
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._authCubit) : super(const ProfileState()) {
    _authSub = _authCubit.stream.listen(_onAuthChanged);
    _recomputeFromAuth(_authCubit.state);
  }

  final AuthCubit _authCubit;
  late final StreamSubscription<AuthState> _authSub;

  Future<void> load() async {
    final info = await PackageInfo.fromPlatform();
    emit(state.copyWith(packageInfo: info));
  }

  Future<void> signOut() async {
    if (state.isSigningOut) return;
    emit(state.copyWith(isSigningOut: true));
    await _authCubit.signOut();
  }

  void _onAuthChanged(AuthState authState) {
    _recomputeFromAuth(authState);
  }

  void _recomputeFromAuth(AuthState authState) {
    if (authState is AuthAuthenticated) {
      emit(
        state.copyWith(
          username: authState.user.username,
          userId: authState.user.id,
        ),
      );
    } else {
      emit(
        state.copyWith(username: '', userId: ''),
      );
    }
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }
}
