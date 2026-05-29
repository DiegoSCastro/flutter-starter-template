import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'profile_state.dart';

part 'profile_event.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._authBloc)
    : super(_stateFromAuth(const ProfileState(), _authBloc.state)) {
    on<ProfileLoaded>(_onLoaded, transformer: sequential());
    on<ProfileSignOutRequested>(
      _onSignOutRequested,
      transformer: sequential(),
    );
    on<_ProfileAuthChanged>(_onAuthChanged, transformer: sequential());
    _authSub = _authBloc.stream.listen((authState) {
      if (isClosed) return;
      add(_ProfileAuthChanged(authState));
    });
  }

  final AuthBloc _authBloc;
  late final StreamSubscription<AuthState> _authSub;

  Future<void> load() {
    final completion = stream.firstWhere((state) => state.packageInfo != null);
    add(const ProfileLoaded());
    return completion.then((_) {});
  }

  Future<void> signOut() {
    if (state.isSigningOut) return Future<void>.value();
    final completion = stream.firstWhere((state) => !state.isSigningOut);
    add(const ProfileSignOutRequested());
    return completion.then((_) {});
  }

  Future<void> _onLoaded(
    ProfileLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final info = await PackageInfo.fromPlatform();
      emit(state.copyWith(packageInfo: info));
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _onSignOutRequested(
    ProfileSignOutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state.isSigningOut) {
        return;
      }
      emit(state.copyWith(isSigningOut: true));
      await _authBloc.signOut();
      if (state.isSigningOut) {
        emit(state.copyWith(isSigningOut: false));
      }
    } catch (_) {
      if (state.isSigningOut) {
        emit(state.copyWith(isSigningOut: false));
      }
      rethrow;
    }
  }

  void _onAuthChanged(
    _ProfileAuthChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(_stateFromAuth(state, event.authState));
  }

  static ProfileState _stateFromAuth(
    ProfileState state,
    AuthState authState,
  ) {
    if (authState is AuthAuthenticated) {
      return state.copyWith(
        username: authState.user.username,
        userId: authState.user.id,
      );
    }
    return state.copyWith(username: '', userId: '', isSigningOut: false);
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }
}
