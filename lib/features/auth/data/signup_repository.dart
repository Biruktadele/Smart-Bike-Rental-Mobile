import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'auth_config.dart';
import 'auth_models.dart';
import 'auth_repository.dart';
import 'signup_models.dart';

abstract class SignupRepository {
  Future<SignupResponse> signup(SignupRequest request);
}

class SignupRepositoryImpl implements SignupRepository {
  SignupRepositoryImpl({
    required this.config,
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final AuthConfig config;
  final ApiClient _apiClient;

  @override
  Future<SignupResponse> signup(SignupRequest request) async {
    if (config.useMock) {
      return _mockSignup(request);
    }
    return _remoteSignup(request);
  }

  Future<SignupResponse> _mockSignup(SignupRequest request) async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (request.name.trim().isEmpty ||
        request.email.trim().isEmpty ||
        request.phone.trim().isEmpty ||
        request.password.trim().isEmpty) {
      throw AuthException('All fields are required.');
    }

    if (!request.email.contains('@')) {
      throw AuthException('Please enter a valid email address.');
    }

    if (request.password.trim().length < 6) {
      throw AuthException('Password must be at least 6 characters.');
    }

    return SignupResponse(
      token: 'mock-signup-token-123',
      user: AuthUser(
        id: 'u_002',
        name: request.name.trim(),
        email: request.email.trim(),
      ),
    );
  }

  Future<SignupResponse> _remoteSignup(SignupRequest request) async {
    try {
      final response = await _apiClient.post(
        config.signupPath,
        body: jsonEncode(request.toJson()),
        withAuth: false,
      );
      if (response.body.isEmpty) {
        throw AuthException('Empty response from server.');
      }

      final decoded = _safeDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return SignupResponse.fromJson(decoded);
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
