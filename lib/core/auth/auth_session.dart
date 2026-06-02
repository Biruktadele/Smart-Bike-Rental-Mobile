class AuthSession {
  const AuthSession({
    required this.token,
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
  });

  final String token;
  final int userId;
  final String email;
  final String name;
  final String role;
}
