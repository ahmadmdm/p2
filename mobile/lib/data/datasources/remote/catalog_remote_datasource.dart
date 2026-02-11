import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalog_remote_datasource.g.dart';

@riverpod
CatalogRemoteDataSource catalogRemoteDataSource(CatalogRemoteDataSourceRef ref) {
  // TODO: Use a proper Dio provider with interceptors and base URL from config
  return CatalogRemoteDataSource(Dio(BaseOptions(baseUrl: 'http://localhost:3000')));
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
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch categories');
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
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch products');
    }
  }
}
