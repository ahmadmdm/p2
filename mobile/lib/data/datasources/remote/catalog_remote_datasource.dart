import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/network_service.dart';

part 'catalog_remote_datasource.g.dart';

@riverpod
CatalogRemoteDataSource catalogRemoteDataSource(
    CatalogRemoteDataSourceRef ref) {
  return CatalogRemoteDataSource(ref.watch(networkServiceProvider));
}

class CatalogRemoteDataSource {
  final Dio _dio;

  CatalogRemoteDataSource(this._dio);

  Future<List<dynamic>> getCategories(String token) async {
    try {
      final response = await _dio.get(
        '/catalog/categories',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch categories');
    }
  }

  Future<List<dynamic>> getProducts(String token) async {
    try {
      final response = await _dio.get(
        '/catalog/products',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch products');
    }
  }
}
