import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/error/failure.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default('') String username,
    @Default('') String userId,
    @Default(false) bool isSigningOut,
    PackageInfo? packageInfo,
    Failure? failure,
  }) = _ProfileState;
}
