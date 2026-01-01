import 'package:flutter/foundation.dart';

class AppConfig {
  // API Configuration
  // In production, this will be set from environment or replaced during build
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultApiUrl,
  );

  // Production API URL - UPDATE THIS after deploying to Render
  // Format: https://your-app-name.onrender.com
  static const String productionApiUrl = 'https://fluentmind-api.onrender.com';

  // Environment-based default API URL
  static const String _defaultApiUrl = isProduction
      ? productionApiUrl
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
    defaultValue: false, // Disabled by default - use real backend
  );

  // Audio settings
  static const int audioSampleRate = 44100;
  static const int maxRecordingDuration = 60; // seconds

  // API timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  /// Get the effective API URL based on current environment
  static String get effectiveApiUrl {
    // If production flag is set, always use production URL
    if (isProduction) {
      return productionApiUrl;
    }
    // Otherwise use the default (local) URL
    return apiBaseUrl;
  }
}
