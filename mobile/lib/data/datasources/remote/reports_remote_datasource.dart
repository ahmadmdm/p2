import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/network_service.dart';

part 'reports_remote_datasource.g.dart';

@riverpod
ReportsRemoteDataSource reportsRemoteDataSource(
    ReportsRemoteDataSourceRef ref) {
  return ReportsRemoteDataSource(ref.watch(networkServiceProvider));
}

class ReportsRemoteDataSource {
  final Dio _dio;

  ReportsRemoteDataSource(this._dio);

  Future<dynamic> getDailySales(String token) async {
    final response = await _dio.get(
      '/reports/daily-sales',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<List<dynamic>> getTopProducts(String token) async {
    final response = await _dio.get(
      '/reports/top-products',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<List<dynamic>> getLowStockAlerts(String token) async {
    final response = await _dio.get(
      '/reports/low-stock',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<List<dynamic>> getSalesByCategory(String token) async {
    final response = await _dio.get(
      '/reports/sales-by-category',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }
}
