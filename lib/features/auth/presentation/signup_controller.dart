import 'package:flutter/foundation.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/auth/token_storage.dart';
import '../data/auth_repository.dart';
import '../data/signup_models.dart';
import '../data/signup_repository.dart';

enum SignupStatus { idle, loading, success, error }

class SignupController extends ChangeNotifier {
  SignupController({
    required SignupRepository repository,
    required TokenStorage tokenStorage,
  })  : _repository = repository,
        _tokenStorage = tokenStorage;

  final SignupRepository _repository;
  final TokenStorage _tokenStorage;

  SignupStatus _status = SignupStatus.idle;
  String? _errorMessage;
  SignupResponse? _response;

  SignupStatus get status => _status;
  String? get errorMessage => _errorMessage;
  SignupResponse? get response => _response;
  bool get isLoading => _status == SignupStatus.loading;

  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        phone.trim().isEmpty ||
        password.trim().isEmpty) {
      _setError('All fields are required.');
      return false;
    }

    if (!email.contains('@')) {
      _setError('Please enter a valid email address.');
      return false;
    }

    if (password.trim().length < 6) {
      _setError('Password must be at least 6 characters.');
      return false;
    }

    _setLoading();
    try {
      final result = await _repository.signup(
        SignupRequest(
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim(),
          password: password,
        ),
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
      _status = SignupStatus.success;
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
    if (_status == SignupStatus.error) {
      _status = SignupStatus.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setLoading() {
    _status = SignupStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = SignupStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
