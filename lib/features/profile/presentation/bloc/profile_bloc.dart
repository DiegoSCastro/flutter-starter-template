import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/analytics/analytics_extensions.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/future_extensions.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/domain/usecases/sign_out.dart';
import 'profile_state.dart';

part 'profile_event.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._signOut, this._analytics) : super(const ProfileState()) {
    on<ProfileLoaded>(_onLoaded, transformer: sequential());
    on<ProfileSignOutRequested>(
      _onSignOutRequested,
      transformer: sequential(),
    );
  }

  final SignOut _signOut;
  final AnalyticsService _analytics;

  Future<void> _onLoaded(
    ProfileLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        username: event.user?.username ?? '',
        userId: event.user?.id ?? '',
      ),
    );
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
      emit(state.copyWith(isSigningOut: true, failure: null));
      final result = await _signOut();
      switch (result) {
        case Ok<void>():
          _analytics.trackSignOut().uw();
          _analytics.setCurrentUser(null).uw();
          emit(
            state.copyWith(
              username: '',
              userId: '',
              isSigningOut: false,
              signOutSucceeded: true,
            ),
          );
        case Err(:final failure):
          _analytics.setCurrentUser(null).uw();
          emit(
            state.copyWith(
              username: '',
              userId: '',
              isSigningOut: false,
              signOutSucceeded: true,
              failure: failure,
            ),
          );
      }
    } catch (_) {
      if (state.isSigningOut) {
        emit(state.copyWith(isSigningOut: false));
      }
      rethrow;
    }
  }
}
