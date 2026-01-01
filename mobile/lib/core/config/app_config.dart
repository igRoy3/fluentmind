import 'package:flutter/foundation.dart';

class AppConfig {
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultApiUrl,
  );

  // Environment-based default API URL
  // For real device testing: use your computer's local IP
  // Run `ipconfig` (Windows) or `ifconfig` (Mac/Linux) to find your IP
  // Example: 'http://192.168.1.100:8000'
  static const String _defaultApiUrl = isProduction
      ? 'https://api.fluentmind.app' // TODO: Replace with your production API URL
      : kDebugMode
      ? 'http://10.0.2.2:8000' // Android emulator localhost
      : 'http://localhost:8000'; // iOS simulator

  // Feature flags
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );

  static const bool isProduction = bool.fromEnvironment(
    'IS_PRODUCTION',
    defaultValue: false,
  );

  // Enable mock mode when backend is unavailable
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: true, // Enable by default for easier testing
  );

  // Audio settings
  static const int audioSampleRate = 44100;
  static const int maxRecordingDuration = 60; // seconds

  // API timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
