import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/network_service.dart';

part 'customers_remote_datasource.g.dart';

@riverpod
CustomersRemoteDataSource customersRemoteDataSource(
    CustomersRemoteDataSourceRef ref) {
  return CustomersRemoteDataSource(ref.watch(networkServiceProvider));
}

class CustomersRemoteDataSource {
  final Dio _dio;

  CustomersRemoteDataSource(this._dio);

  Future<List<dynamic>> searchCustomers(String token, String query) async {
    try {
      final response = await _dio.get(
        '/customers',
        queryParameters: {'search': query},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to search customers');
    }
  }

  Future<dynamic> createCustomer(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/customers',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to create customer');
    }
  }

  Future<List<dynamic>> getLoyaltyHistory(
      String token, String customerId) async {
    try {
      final response = await _dio.get(
        '/customers/$customerId/loyalty-history',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to get loyalty history');
    }
  }
}
