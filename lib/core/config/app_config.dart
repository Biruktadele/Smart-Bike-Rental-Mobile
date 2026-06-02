class AppConfig {
  const AppConfig({
    required this.baseUrl,
  });

  final String baseUrl;

  String resolve(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$normalizedBase$normalizedPath';
  }
}

const appConfig = AppConfig(
  baseUrl: 'https://smart-bike-rental-backend.onrender.com/api',
);
