import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/bloc/event_completion.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'profile_state.dart';

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
    final completer = Completer<void>();
    add(ProfileLoaded(completer: completer));
    return completer.future;
  }

  Future<void> signOut() {
    if (state.isSigningOut) return Future<void>.value();
    final completer = Completer<void>();
    add(ProfileSignOutRequested(completer: completer));
    return completer.future;
  }

  Future<void> _onLoaded(
    ProfileLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final info = await PackageInfo.fromPlatform();
      emit(state.copyWith(packageInfo: info));
      event.completer.completeVoidIfPending();
    } catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
      rethrow;
    }
  }

  Future<void> _onSignOutRequested(
    ProfileSignOutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state.isSigningOut) {
        event.completer.completeVoidIfPending();
        return;
      }
      emit(state.copyWith(isSigningOut: true));
      await _authBloc.signOut();
      event.completer.completeVoidIfPending();
    } catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
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
    return state.copyWith(username: '', userId: '');
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }
}

sealed class ProfileEvent {
  const ProfileEvent();
}

final class ProfileLoaded extends ProfileEvent {
  const ProfileLoaded({this.completer});

  final Completer<void>? completer;
}

final class ProfileSignOutRequested extends ProfileEvent {
  const ProfileSignOutRequested({this.completer});

  final Completer<void>? completer;
}

final class _ProfileAuthChanged extends ProfileEvent {
  const _ProfileAuthChanged(this.authState);

  final AuthState authState;
}
