import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/network_service.dart';

final usersRemoteDataSourceProvider = Provider<UsersRemoteDataSource>((ref) {
  return UsersRemoteDataSource(ref.watch(networkServiceProvider));
});

class UsersRemoteDataSource {
  final Dio _dio;

  UsersRemoteDataSource(this._dio);

  Future<List<dynamic>> getUsers(String token) async {
    final response = await _dio.get(
      '/users',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<dynamic> createUser(String token, Map<String, dynamic> data) async {
    final response = await _dio.post(
      '/users',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<dynamic> updateUser(
      String token, String id, Map<String, dynamic> data) async {
    final response = await _dio.put(
      '/users/$id',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<void> deleteUser(String token, String id) async {
    await _dio.delete(
      '/users/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
