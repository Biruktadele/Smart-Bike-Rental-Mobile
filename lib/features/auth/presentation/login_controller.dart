import 'package:flutter/foundation.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/auth/token_storage.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

enum LoginStatus { idle, loading, success, error }

class LoginController extends ChangeNotifier {
  LoginController({
    required AuthRepository repository,
    required TokenStorage tokenStorage,
  })  : _repository = repository,
        _tokenStorage = tokenStorage;

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;

  LoginStatus _status = LoginStatus.idle;
  String? _errorMessage;
  LoginResponse? _response;

  LoginStatus get status => _status;
  String? get errorMessage => _errorMessage;
  LoginResponse? get response => _response;
  bool get isLoading => _status == LoginStatus.loading;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty || password.trim().isEmpty) {
      _setError('Email and password are required.');
      return false;
    }

    if (password.trim().length < 6) {
      _setError('Password must be at least 6 characters.');
      return false;
    }

    _setLoading();
    try {
      final result = await _repository.login(
        LoginRequest(email: trimmedEmail, password: password),
      );
      await _tokenStorage.saveSession(
        AuthSession(
          token: result.token,
          userId: int.tryParse(result.user.id) ?? 0,
          email: result.user.email,
          name: result.user.name,
          role: result.user.role,
        ),
      );
      _response = result;
      _status = LoginStatus.success;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Unexpected error occurred. Please try again.');
      return false;
    }
  }

  void resetError() {
    if (_status == LoginStatus.error) {
      _status = LoginStatus.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setLoading() {
    _status = LoginStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = LoginStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
