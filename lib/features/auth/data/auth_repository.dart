import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'auth_config.dart';
import 'auth_models.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(LoginRequest request);
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.config,
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final AuthConfig config;
  final ApiClient _apiClient;

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    if (config.useMock) {
      return _mockLogin(request);
    }
    return _remoteLogin(request);
  }

  Future<LoginResponse> _mockLogin(LoginRequest request) async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (request.email.trim().isEmpty || request.password.trim().isEmpty) {
      throw AuthException('Please enter both email and password.');
    }

    if (request.password.length < 6) {
      throw AuthException('Password must be at least 6 characters.');
    }

    return LoginResponse(
      token: 'mock-token-123',
      user: AuthUser(
        id: 'u_001',
        name: 'Biruk Rider',
        email: request.email.contains('@')
            ? request.email.trim()
            : 'rider@velocity.app',
      ),
    );
  }

  Future<LoginResponse> _remoteLogin(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        config.loginPath,
        body: jsonEncode(request.toJson()),
        withAuth: false,
      );
      if (response.body.isEmpty) {
        throw AuthException('Empty response from server.');
      }

      final decoded = _safeDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return LoginResponse.fromJson(decoded);
      }

      throw AuthException('Unexpected response from server.');
    } on ApiException catch (e) {
      throw AuthException(e.message);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException('Network error. Please try again.');
    }
  }

  dynamic _safeDecode(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      throw AuthException('Unexpected response from server.');
    }
  }
}
