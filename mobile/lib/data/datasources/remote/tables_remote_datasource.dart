import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/network_service.dart';

part 'tables_remote_datasource.g.dart';

@riverpod
TablesRemoteDataSource tablesRemoteDataSource(TablesRemoteDataSourceRef ref) {
  return TablesRemoteDataSource(ref.watch(networkServiceProvider));
}

class TablesRemoteDataSource {
  final Dio _dio;

  TablesRemoteDataSource(this._dio);

  Future<List<dynamic>> getTables(String token) async {
    final response = await _dio.get(
      '/tables',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<void> updateLayout(String token, List<Map<String, dynamic>> tables) async {
    await _dio.post(
      '/tables/layout',
      data: tables,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
