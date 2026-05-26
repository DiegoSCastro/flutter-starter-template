import 'package:flutter/foundation.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required SignIn signIn, required SignOut signOut})
      : _signIn = signIn,
        _signOut = signOut;

  final SignIn _signIn;
  final SignOut _signOut;

  AuthUser? _user;
  AuthUser? get user => _user;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _user != null;

  Future<void> signIn({required String username, required String password}) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _signIn(username: username, password: password);
    switch (result) {
      case Ok(value: final user):
        _user = user;
      case Err(failure: final failure):
        _errorMessage = failure.message;
    }
    _isSubmitting = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    final result = await _signOut();
    if (result is Ok<void>) {
      _user = null;
      _errorMessage = null;
      notifyListeners();
    }
  }
}
