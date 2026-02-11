import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_type.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/station.dart';
import '../../domain/entities/modifier.dart';
import '../../domain/entities/refund.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/remote/orders_remote_datasource.dart';
import '../datasources/local/orders_local_datasource.dart';

part 'orders_repository_impl.g.dart';

@riverpod
OrdersRepository ordersRepository(OrdersRepositoryRef ref) {
  final remoteDataSource = ref.watch(ordersRemoteDataSourceProvider);
  final localDataSource = ref.watch(ordersLocalDataSourceProvider);
  return OrdersRepositoryImpl(remoteDataSource, localDataSource);
}

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource _remoteDataSource;
  final OrdersLocalDataSource _localDataSource;
  final _uuid = const Uuid();

  OrdersRepositoryImpl(this._remoteDataSource, this._localDataSource);

  bool _isTakeawayTableHint(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'takeaway' ||
        normalized == 'take away' ||
        normalized == 'to go' ||
        normalized == 'pickup' ||
        normalized == 'سفري';
  }

  String? _resolveTableIdentifier(Order order) {
    final raw = order.tableNumber?.trim();
    if (raw == null || raw.isEmpty || _isTakeawayTableHint(raw)) {
      return null;
    }
    return raw;
  }

  OrderType _resolveOrderTypeForSync(Order order, String? tableIdentifier) {
    if (order.type == OrderType.DINE_IN &&
        (tableIdentifier == null || tableIdentifier.isEmpty)) {
      return OrderType.TAKEAWAY;
    }
    return order.type;
  }

  bool _isDineInTableError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('table not found') ||
        message.contains('table id is required for dine-in orders');
  }

  Map<String, dynamic> _buildCreateOrderDto({
    required Order order,
    required String? tableIdentifier,
    required OrderType orderType,
  }) {
    return {
      'tableId': tableIdentifier,
      'type': orderType.name,
      'deliveryAddress': order.deliveryAddress,
      'deliveryFee': order.deliveryFee,
      'taxAmount': order.taxAmount,
      'discountAmount': order.discountAmount,
      'paymentMethod': order.paymentMethod,
      'customerId': order.customerId,
      'items': order.items
          .map((item) => {
                'productId': item.product.id,
                'quantity': item.quantity,
                'taxAmount': item.taxAmount,
                'discountAmount': item.discountAmount,
                'notes': item.notes,
                'status': item.status,
                'modifiers': item.modifiers.map((m) => m.toJson()).toList(),
              })
          .toList(),
    };
  }

  @override
  Future<List<Order>> fetchOrders(String token) async {
    // 1. Fetch Remote Orders
    List<Order> remoteOrders = [];
    try {
      final data = await _remoteDataSource.getOrders(token);
      remoteOrders = data.map((json) => _mapOrder(json)).toList();
    } catch (e) {
      // If offline or error, we might only show local unsynced orders + maybe cached remote orders?
      // For now, if remote fails, we just return empty list or rethrow?
      // Better to return empty list so we can at least see local orders.
      print('Failed to fetch remote orders: $e');
    }

    // 2. Fetch Local Unsynced Orders
    final localOrders = await _localDataSource.getUnsyncedOrders();

    // 3. Merge (Local orders first to show them as pending?)
    // Or just combine.
    return [...localOrders, ...remoteOrders];
  }

  @override
  Future<void> updateOrderStatus(
      String token, String orderId, OrderStatus status) async {
    // Check if it's a local order (unsynced) - usually we don't update status of unsynced orders remotely
    // But if we are offline, we might want to update local status.
    // For MVP, assume we only update remote orders or if online.
    await _remoteDataSource.updateOrderStatus(token, orderId, status.name);
  }

  @override
  Future<Order> createOrder(Order order, {String? token}) async {
    // 1. Assign a temporary ID if not present (though entity usually has it)
    final tempId = order.id.isEmpty ? _uuid.v4() : order.id;
    final normalizedItems =
        order.items.map((item) => item.copyWith(id: _uuid.v4())).toList();
    final orderToSave = order.copyWith(
      id: tempId,
      status: OrderStatus.PENDING,
      items: normalizedItems,
    );

    // 2. Save to Local DB (Always save locally first for offline-first)
    await _localDataSource.saveOrder(orderToSave);

    // 3. If Online (token provided), try to Sync
    if (token != null) {
      try {
        final tableIdentifier = _resolveTableIdentifier(orderToSave);
        final orderType = _resolveOrderTypeForSync(orderToSave, tableIdentifier);

        final dto = _buildCreateOrderDto(
          order: orderToSave,
          tableIdentifier: tableIdentifier,
          orderType: orderType,
        );

        final result = await _remoteDataSource.createOrder(token, dto);

        // 4. If success, remove the temporary local order
        // Because the next fetch will get the real order from backend
        await _localDataSource.deleteOrder(tempId);

        return _mapOrder(result);
      } catch (e) {
        if (_isDineInTableError(e) && orderToSave.type == OrderType.DINE_IN) {
          try {
            final fallbackDto = _buildCreateOrderDto(
              order: orderToSave,
              tableIdentifier: null,
              orderType: OrderType.TAKEAWAY,
            );
            final fallbackResult =
                await _remoteDataSource.createOrder(token, fallbackDto);
            await _localDataSource.deleteOrder(tempId);
            return _mapOrder(fallbackResult);
          } catch (_) {
            // Keep local copy for later retry if fallback also fails.
          }
        }

        // Failed to sync, keep it local (it's already saved with isSynced=false)
        print('Failed to sync order: $e');
        // We could maybe update status to 'failed_sync' if we wanted
        return orderToSave;
      }
    }
    return orderToSave;
  }

  @override
  Future<void> fireCourse(String token, String orderId, String course) async {
    await _remoteDataSource.fireCourse(token, orderId, course);
  }

  @override
  Future<void> assignDriver(
      String token, String orderId, String driverId) async {
    await _remoteDataSource.assignDriver(token, orderId, driverId);
  }

  @override
  Future<List<Order>> getMyDeliveries(String token, String driverId) async {
    final data = await _remoteDataSource.getMyDeliveries(token, driverId);
    return data.map((json) => _mapOrder(json)).toList();
  }

  @override
  Future<void> requestDelivery(
      String token, String orderId, String providerName) async {
    await _remoteDataSource.requestDelivery(token, orderId, providerName);
  }

  @override
  Future<void> cancelDelivery(
      String token, String orderId, String providerName) async {
    await _remoteDataSource.cancelDelivery(token, orderId, providerName);
  }

  @override
  Future<void> requestRefund(
      String token, String orderId, double amount, String reason) async {
    await _remoteDataSource.requestRefund(token, orderId, amount, reason);
  }

  @override
  Future<void> approveRefund(String token, String refundId) async {
    await _remoteDataSource.approveRefund(token, refundId);
  }

  @override
  Future<void> rejectRefund(String token, String refundId) async {
    await _remoteDataSource.rejectRefund(token, refundId);
  }

  @override
  Future<List<Refund>> fetchPendingRefunds(String token) async {
    final data = await _remoteDataSource.getPendingRefunds(token);
    return data.map((json) => Refund.fromJson(json)).toList();
  }

  @override
  Future<void> voidOrder(
      String token, String orderId, String reason, bool returnStock) async {
    await _remoteDataSource.voidOrder(token, orderId, reason, returnStock);
  }

  @override
  Future<void> syncPendingOrders(String token) async {
    final unsyncedOrders = await _localDataSource.getUnsyncedOrders();
    for (final order in unsyncedOrders) {
      try {
        final tableIdentifier = _resolveTableIdentifier(order);
        final orderType = _resolveOrderTypeForSync(order, tableIdentifier);

        final dto = _buildCreateOrderDto(
          order: order,
          tableIdentifier: tableIdentifier,
          orderType: orderType,
        );

        await _remoteDataSource.createOrder(token, dto);

        // Delete local temp order after successful sync
        await _localDataSource.deleteOrder(order.id);
      } catch (e) {
        if (_isDineInTableError(e) && order.type == OrderType.DINE_IN) {
          try {
            final fallbackDto = _buildCreateOrderDto(
              order: order,
              tableIdentifier: null,
              orderType: OrderType.TAKEAWAY,
            );
            await _remoteDataSource.createOrder(token, fallbackDto);
            await _localDataSource.deleteOrder(order.id);
            continue;
          } catch (_) {
            // Keep local order unsynced and continue retry loop.
          }
        }

        print('Failed to sync order ${order.id}: $e');
      }
    }
  }

  Order _mapOrder(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      tableNumber: json['table']?['tableNumber'] ??
          (json['type'] == 'DINE_IN' ? 'Unknown' : null),
      status: parseOrderStatus(json['status']),
      type: parseOrderType(json['type']),
      driverId: json['driverId'],
      deliveryAddress: json['deliveryAddress'],
      deliveryFee: json['deliveryFee'] is String
          ? double.parse(json['deliveryFee'])
          : (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? 'LATER',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      customerId: json['customerId'],
      customerName: json['customer']?['name'],
      notes: json['notes'],
      totalAmount: json['totalAmount'] is String
          ? double.parse(json['totalAmount'])
          : (json['totalAmount'] as num).toDouble(),
      taxAmount: json['taxAmount'] is String
          ? double.parse(json['taxAmount'])
          : (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: json['discountAmount'] is String
          ? double.parse(json['discountAmount'])
          : (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      items: (json['items'] as List)
          .map((itemJson) => _mapOrderItem(itemJson))
          .toList(),
      refunds: json['refunds'] != null
          ? (json['refunds'] as List).map((e) => Refund.fromJson(e)).toList()
          : null,
    );
  }

  OrderItem _mapOrderItem(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'].toString(),
      quantity: json['quantity'],
      price: json['price'] is String
          ? double.parse(json['price'])
          : (json['price'] as num).toDouble(),
      taxAmount: json['taxAmount'] is String
          ? double.parse(json['taxAmount'])
          : (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: json['discountAmount'] is String
          ? double.parse(json['discountAmount'])
          : (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
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
}
