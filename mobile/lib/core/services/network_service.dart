import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_service.g.dart';

@Riverpod(keepAlive: true)
Dio networkService(NetworkServiceRef ref) {
  return Dio(BaseOptions(
    baseUrl: 'http://localhost:3001',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
}
