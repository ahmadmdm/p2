import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_service.g.dart';

@riverpod
Dio dio(Ref ref) {
  const apiBaseUrl = String.fromEnvironment(
    'PUBLIC_API_BASE_URL',
    defaultValue: 'http://localhost:3000/public-api',
  );
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  return dio;
}

@riverpod
class ApiService extends _$ApiService {
  @override
  FutureOr<void> build() {}

  Future<Map<String, dynamic>> getMenu(String token) async {
    final dio = ref.read(dioProvider);
    final response = await dio.get('/menu', queryParameters: {'t': token});
    return response.data;
  }

  Future<dynamic> createOrder(
    String token,
    Map<String, dynamic> orderData,
  ) async {
    final dio = ref.read(dioProvider);
    final response = await dio.post(
      '/orders',
      data: {'token': token, ...orderData},
    );
    return response.data;
  }

  Future<void> requestBill(String token) async {
    final dio = ref.read(dioProvider);
    await dio.post('/request-bill', data: {'token': token});
  }

  Future<dynamic> getActiveOrder(String token) async {
    final dio = ref.read(dioProvider);
    try {
      final response = await dio.get(
        '/active-order',
        queryParameters: {'t': token},
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> addItemsToOrder(
    String token,
    String orderId,
    List<dynamic> items,
  ) async {
    final dio = ref.read(dioProvider);
    final response = await dio.post(
      '/orders/$orderId/add-items',
      queryParameters: {'t': token},
      data: {'items': items},
    );
    return response.data;
  }
}
