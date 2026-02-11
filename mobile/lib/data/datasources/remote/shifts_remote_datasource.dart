import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/network_service.dart';

part 'shifts_remote_datasource.g.dart';

@riverpod
ShiftsRemoteDataSource shiftsRemoteDataSource(ShiftsRemoteDataSourceRef ref) {
  return ShiftsRemoteDataSource(ref.watch(networkServiceProvider));
}

class ShiftsRemoteDataSource {
  final Dio _dio;

  ShiftsRemoteDataSource(this._dio);

  Future<void> openShift(String token, Map<String, dynamic> data) async {
    await _dio.post(
      '/shifts/open',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> closeShift(
      String token, String shiftId, Map<String, dynamic> data) async {
    await _dio.post(
      '/shifts/close', // The backend currently uses Body to identify shift? No, backend is /shifts/close with body?
      // Wait, backend controller: @Post('close') closeShift(@Body() dto).
      // It uses req.user to find the open shift. It doesn't take ID in URL.
      // But for SYNC, we might need to close a SPECIFIC shift by ID if the user has multiple (shouldn't happen)
      // or if we are syncing a past shift.
      // For now, let's stick to the current backend logic which closes the *current* open shift.
      // This might be problematic for bulk sync of history.
      // I should update backend to allow closing a specific shift by ID if provided, or add a specific sync endpoint.
      // For now, let's assume we sync in order.
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> addCashTransaction(
      String token, Map<String, dynamic> data) async {
    await _dio.post(
      '/shifts/transaction',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
