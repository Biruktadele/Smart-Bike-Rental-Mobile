import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.client,
    required this.tokenStorage,
    this.timeout = const Duration(seconds: 20),
  });

  final String baseUrl;
  final http.Client client;
  final TokenStorage tokenStorage;
  final Duration timeout;

  Future<http.Response> get(
    String path, {
    Map<String, String>? query,
    bool withAuth = true,
  }) async {
    final uri = Uri.parse(_resolve(path)).replace(queryParameters: query);
    final headers = await _buildHeaders(withAuth: withAuth);
    try {
      final response = await client.get(uri, headers: headers).timeout(timeout);
      _throwIfError(response);
      return response;
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    }
  }

  Future<http.Response> post(
    String path, {
    Map<String, String>? query,
    Object? body,
    bool withAuth = true,
  }) async {
    final uri = Uri.parse(_resolve(path)).replace(queryParameters: query);
    final headers = await _buildHeaders(withAuth: withAuth, body: body);
    try {
      final response = await client
          .post(uri, headers: headers, body: body)
          .timeout(timeout);
      _throwIfError(response);
      return response;
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    }
  }

  Future<http.Response> put(
    String path, {
    Map<String, String>? query,
    Object? body,
    bool withAuth = true,
  }) async {
    final uri = Uri.parse(_resolve(path)).replace(queryParameters: query);
    final headers = await _buildHeaders(withAuth: withAuth, body: body);
    try {
      final response = await client
          .put(uri, headers: headers, body: body)
          .timeout(timeout);
      _throwIfError(response);
      return response;
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    }
  }

  String _resolve(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$normalizedBase$normalizedPath';
  }

  Future<Map<String, String>> _buildHeaders({required bool withAuth, Object? body}) async {
    final headers = <String, String>{
      'accept': '*/*',
    };
    // Only set application/json if there's actually a body,
    // otherwise some backends reject the request with 403/400.
    if (body != null && body.toString().isNotEmpty) {
      headers['Content-Type'] = 'application/json';
    }

    if (withAuth) {
      final token = await tokenStorage.readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode < 400) return;

    String message = 'Request failed (${response.statusCode}).';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['message'] != null) {
        message = decoded['message'].toString();
      }
    } catch (_) {}

    throw ApiException(message, statusCode: response.statusCode);
  }
}
