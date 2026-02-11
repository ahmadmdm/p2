import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/network_service.dart';

part 'orders_remote_datasource.g.dart';

@riverpod
OrdersRemoteDataSource ordersRemoteDataSource(OrdersRemoteDataSourceRef ref) {
  return OrdersRemoteDataSource(ref.watch(networkServiceProvider));
}

class OrdersRemoteDataSource {
  final Dio _dio;

  OrdersRemoteDataSource(this._dio);

  Future<List<dynamic>> getOrders(String token) async {
    try {
      final response = await _dio.get(
        '/orders',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch orders');
    }
  }

  Future<dynamic> updateOrderStatus(
      String token, String orderId, String status) async {
    try {
      final response = await _dio.put(
        '/orders/$orderId/status',
        data: {'status': status},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to update order status');
    }
  }

  Future<dynamic> createOrder(String token, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/orders',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create order');
    }
  }

  Future<void> fireCourse(String token, String orderId, String course) async {
    try {
      await _dio.post(
        '/orders/$orderId/fire',
        data: {'course': course},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fire course');
    }
  }

  Future<void> assignDriver(
      String token, String orderId, String driverId) async {
    try {
      await _dio.post(
        '/orders/$orderId/assign-driver',
        data: {'driverId': driverId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to assign driver');
    }
  }

  Future<List<dynamic>> getMyDeliveries(String token, String driverId) async {
    try {
      final response = await _dio.get(
        '/orders/driver/$driverId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch deliveries');
    }
  }

  Future<void> requestDelivery(
      String token, String orderId, String providerName) async {
    try {
      await _dio.post(
        '/delivery/request/$orderId',
        data: {'provider': providerName},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to request delivery');
    }
  }

  Future<void> cancelDelivery(
      String token, String orderId, String providerName) async {
    try {
      await _dio.post(
        '/delivery/cancel/$orderId',
        data: {'providerName': providerName},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to cancel delivery');
    }
  }

  Future<void> requestRefund(
      String token, String orderId, double amount, String reason) async {
    try {
      await _dio.post(
        '/orders/$orderId/refund',
        data: {'amount': amount, 'reason': reason},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to request refund');
    }
  }

  Future<void> approveRefund(String token, String refundId) async {
    try {
      await _dio.post(
        '/orders/refunds/$refundId/approve',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to approve refund');
    }
  }

  Future<void> rejectRefund(String token, String refundId) async {
    try {
      await _dio.post(
        '/orders/refunds/$refundId/reject',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to reject refund');
    }
  }

  Future<List<dynamic>> getPendingRefunds(String token) async {
    try {
      final response = await _dio.get(
        '/orders/refunds/pending',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch pending refunds');
    }
  }

  Future<void> voidOrder(
      String token, String orderId, String reason, bool returnStock) async {
    try {
      await _dio.post(
        '/orders/$orderId/void',
        data: {'reason': reason, 'returnStock': returnStock},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to void order');
    }
  }
}
