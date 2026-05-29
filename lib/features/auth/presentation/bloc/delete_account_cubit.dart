import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/analytics/analytics_extensions.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/future_extensions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/usecases/delete_account.dart';
import 'delete_account_state.dart';

@injectable
class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit(this._deleteAccount, this._analytics)
    : super(const DeleteAccountState.initial());

  final DeleteAccount _deleteAccount;
  final AnalyticsService _analytics;

  Future<void> submit() async {
    if (state is DeleteAccountSubmitting) return;

    emit(const DeleteAccountState.submitting());

    final result = await _deleteAccount();

    switch (result) {
      case Ok():
        _analytics.trackAccountDeleted().uw();
        _analytics.setCurrentUser(null).uw();
        emit(const DeleteAccountState.success());
      case Err(:final failure):
        emit(DeleteAccountState.failure(failure));
    }
  }
}
