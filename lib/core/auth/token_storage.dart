import 'package:shared_preferences/shared_preferences.dart';

import 'auth_session.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _emailKey = 'auth_email';
  static const _nameKey = 'auth_name';
  static const _roleKey = 'auth_role';

  Future<AuthSession?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userId = prefs.getInt(_userIdKey);
    final email = prefs.getString(_emailKey);
    final name = prefs.getString(_nameKey);
    final role = prefs.getString(_roleKey);

    if (token == null || userId == null || email == null || name == null) {
      return null;
    }

    return AuthSession(
      token: token,
      userId: userId,
      email: email,
      name: name,
      role: role ?? 'USER',
    );
  }

  Future<void> saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, session.token);
    await prefs.setInt(_userIdKey, session.userId);
    await prefs.setString(_emailKey, session.email);
    await prefs.setString(_nameKey, session.name);
    await prefs.setString(_roleKey, session.role);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_roleKey);
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<int?> readUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }
}
