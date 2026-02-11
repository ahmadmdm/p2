import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/network_service.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/order_item.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/station.dart';
import '../../../domain/entities/modifier.dart';
import '../../../domain/entities/order_status.dart';

part 'kitchen_remote_datasource.g.dart';

@riverpod
KitchenRemoteDataSource kitchenRemoteDataSource(
    KitchenRemoteDataSourceRef ref) {
  return KitchenRemoteDataSource(ref.watch(networkServiceProvider));
}

class KitchenRemoteDataSource {
  final Dio _dio;

  KitchenRemoteDataSource(this._dio);

  Future<List<dynamic>> getStations() async {
    final response = await _dio.get('/kitchen/stations');
    return response.data;
  }

  Future<dynamic> createStation(String name, String? printerName) async {
    final response = await _dio.post('/kitchen/stations', data: {
      'name': name,
      'printerName': printerName,
    });
    return response.data;
  }

  Future<List<Order>> getKdsOrders(String? stationId) async {
    final response = await _dio.get('/kitchen/orders', queryParameters: {
      if (stationId != null) 'stationId': stationId,
    });
    return (response.data as List).map((json) => _mapOrder(json)).toList();
  }

  Future<void> updateItemStatus(String itemId, String status) async {
    await _dio.patch('/kitchen/items/$itemId/status', data: {'status': status});
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _dio.patch('/orders/$orderId/status', data: {'status': status});
  }

  Order _mapOrder(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      tableNumber: json['table']?['tableNumber'] ?? 'Unknown',
      status: _parseOrderStatus(json['status']),
      paymentMethod: json['paymentMethod'] ?? 'LATER',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      totalAmount: json['totalAmount'] is String
          ? double.parse(json['totalAmount'])
          : (json['totalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      items: (json['items'] as List)
          .map((itemJson) => _mapOrderItem(itemJson))
          .toList(),
    );
  }

  OrderItem _mapOrderItem(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'].toString(),
      quantity: json['quantity'],
      price: json['price'] is String
          ? double.parse(json['price'])
          : (json['price'] as num).toDouble(),
      notes: json['notes'],
      modifiers: json['modifiers'] != null
          ? (json['modifiers'] as List)
              .map((e) => ModifierItem.fromJson(e))
              .toList()
          : [],
      product: _mapProduct(json['product']),
      status: json['status'] ?? 'PENDING',
    );
  }

  Product _mapProduct(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      categoryId: json['category']?['id'] ?? '',
      nameEn: json['name']['en'],
      nameAr: json['name']['ar'],
      price: json['price'] is String
          ? double.parse(json['price'])
          : (json['price'] as num).toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      course: json['course'] ?? 'OTHER',
      station: json['station'] != null ? _mapStation(json['station']) : null,
    );
  }

  Station _mapStation(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      name: json['name'],
      printerName: json['printerName'],
      printerIp: json['printerIp'],
      printerPort: json['printerPort'] ?? 9100,
    );
  }

  OrderStatus _parseOrderStatus(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => OrderStatus.PENDING,
    );
  }
}
