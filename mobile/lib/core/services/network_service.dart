import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/features/settings/settings_controller.dart';

part 'network_service.g.dart';

const _defaultApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

@Riverpod(keepAlive: true)
Dio networkService(NetworkServiceRef ref) {
  final settingsAsync = ref.watch(settingsControllerProvider);
  final configuredBaseUrl = settingsAsync.value?['baseUrl']?.toString().trim();
  final baseUrl = (configuredBaseUrl != null && configuredBaseUrl.isNotEmpty)
      ? configuredBaseUrl
      : _defaultApiBaseUrl;

  return Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
}
