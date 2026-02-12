import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/network_service.dart';

part 'auth_remote_datasource.g.dart';

@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  return AuthRemoteDataSource(ref.watch(networkServiceProvider));
}

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Unexpected login response');
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      throw Exception('Unable to connect to server');
    }
  }
}
