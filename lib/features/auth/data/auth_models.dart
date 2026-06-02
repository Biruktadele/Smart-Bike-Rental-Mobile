class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'USER',
  });

  final String id;
  final String name;
  final String email;
  final String role;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'USER').toString(),
    );
  }
}

class LoginResponse {
  const LoginResponse({
    required this.token,
    required this.user,
    this.message,
  });

  final String token;
  final AuthUser user;
  final String? message;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final userId = (json['userId'] ?? '').toString();
    final email = (json['email'] ?? '').toString();
    final name = (json['name'] ?? '').toString();
    final role = (json['role'] ?? 'USER').toString();
    return LoginResponse(
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
