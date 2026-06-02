import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'auth_config.dart';
import 'auth_repository.dart';

class OtpRepository {
  OtpRepository({
    required this.config,
    required this.apiClient,
  });

  final AuthConfig config;
  final ApiClient apiClient;

  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      await apiClient.post(
        config.otpVerifyPath,
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
        withAuth: false,
      );
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<void> resendOtp({
    required String email,
  }) async {
    try {
      await apiClient.post(
        config.otpResendPath,
        body: jsonEncode({'email': email}),
        withAuth: false,
      );
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }
}
