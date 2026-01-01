import 'package:flutter/foundation.dart';

class AppConfig {
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultApiUrl,
  );

  // Environment-based default API URL
  static const String _defaultApiUrl = isProduction
      ? 'https://api.fluentmind.app' // TODO: Replace with your production API URL
      : kDebugMode
      ? 'http://10.0.2.2:8000' // Android emulator
      : 'http://localhost:8000'; // iOS simulator

  // For real device testing on local network:
  // Use your computer's local IP: 'http://192.168.1.XXX:8000'

  // Feature flags
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );

  static const bool isProduction = bool.fromEnvironment(
    'IS_PRODUCTION',
    defaultValue: false,
  );

  // Audio settings
  static const int audioSampleRate = 44100;
  static const int maxRecordingDuration = 60; // seconds

  // API timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
