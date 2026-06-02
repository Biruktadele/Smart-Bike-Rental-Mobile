import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'auth_config.dart';
import 'auth_repository.dart';

class PasswordResetRepository {
  PasswordResetRepository({
    required this.config,
    required this.apiClient,
  });

  final AuthConfig config;
  final ApiClient apiClient;

  Future<void> requestReset({
    required String email,
  }) async {
    try {
      await apiClient.post(
        config.forgotPasswordPath,
        body: jsonEncode({'email': email}),
        withAuth: false,
      );
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }
}
