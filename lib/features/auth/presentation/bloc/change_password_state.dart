import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failure.dart';

part 'change_password_state.freezed.dart';

@freezed
class ChangePasswordState with _$ChangePasswordState {
  const factory ChangePasswordState.initial() = _Initial;
  const factory ChangePasswordState.submitting() = _Submitting;
  const factory ChangePasswordState.success() = _Success;
  const factory ChangePasswordState.failure(Failure failure) = _Failure;
}
