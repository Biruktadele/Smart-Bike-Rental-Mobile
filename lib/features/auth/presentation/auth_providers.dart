import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/auth/token_storage.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../data/auth_config.dart';
import '../data/auth_repository.dart';
import '../data/otp_repository.dart';
import '../data/password_reset_repository.dart';
import '../data/signup_repository.dart';
import 'login_controller.dart';
import 'signup_controller.dart';

final authConfigProvider = Provider<AuthConfig>((ref) => authConfig);

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: appConfig.baseUrl,
    client: ref.watch(httpClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    config: ref.watch(authConfigProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});

final signupRepositoryProvider = Provider<SignupRepository>((ref) {
  return SignupRepositoryImpl(
    config: ref.watch(authConfigProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});

final otpRepositoryProvider = Provider<OtpRepository>((ref) {
  return OtpRepository(
    config: ref.watch(authConfigProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});

final passwordResetRepositoryProvider = Provider<PasswordResetRepository>((ref) {
  return PasswordResetRepository(
    config: ref.watch(authConfigProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});

final loginControllerProvider = ChangeNotifierProvider<LoginController>((ref) {
  return LoginController(
    repository: ref.watch(authRepositoryProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final signupControllerProvider = ChangeNotifierProvider<SignupController>((ref) {
  return SignupController(
    repository: ref.watch(signupRepositoryProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final sessionProvider = FutureProvider((ref) {
  return ref.watch(tokenStorageProvider).loadSession();
});
