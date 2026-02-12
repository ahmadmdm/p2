import 'package:flutter/foundation.dart';

const _apiBaseUrlFromEnv = String.fromEnvironment('API_BASE_URL');

String defaultApiBaseUrl() {
  final fromEnv = _apiBaseUrlFromEnv.trim();
  if (fromEnv.isNotEmpty) return fromEnv;

  if (kIsWeb) return 'http://localhost:3000';

  // Android emulators cannot reach host services through localhost.
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }

  return 'http://localhost:3000';
}
