import 'auth_models.dart';

class SignupRequest {
  const SignupRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  final String name;
  final String email;
  final String phone;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }
}

class SignupResponse {
  const SignupResponse({
    required this.token,
    required this.user,
    this.message,
  });

  final String token;
  final AuthUser user;
  final String? message;

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    final userId = (json['userId'] ?? '').toString();
    final email = (json['email'] ?? '').toString();
    final name = (json['name'] ?? '').toString();
    final role = (json['role'] ?? 'USER').toString();
    return SignupResponse(
      token: (json['token'] ?? '').toString(),
      message: json['message']?.toString(),
      user: AuthUser(
        id: userId,
        email: email,
        name: name,
        role: role,
      ),
    );
  }
}
