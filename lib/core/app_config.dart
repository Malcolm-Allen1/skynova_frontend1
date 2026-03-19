class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'APP_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000/api',
  );
}