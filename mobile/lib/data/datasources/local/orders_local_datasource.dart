import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';
import 'database.dart';
import '../../../domain/entities/order.dart' as domain;
import '../../../domain/entities/order_item.dart' as domain;
import '../../../domain/entities/order_status.dart';
import '../../../domain/entities/product.dart' as domain;
import '../../../domain/entities/modifier.dart';

part 'orders_local_datasource.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase();
}

@riverpod
OrdersLocalDataSource ordersLocalDataSource(OrdersLocalDataSourceRef ref) {
  return OrdersLocalDataSource(ref.watch(appDatabaseProvider));
}

class OrdersLocalDataSource {
  final AppDatabase _db;

  OrdersLocalDataSource(this._db);

  Future<void> saveOrder(domain.Order order) async {
    await _db.transaction(() async {
      await _db.into(_db.orders).insert(OrdersCompanion.insert(
            id: order.id,
            status: order.status.name,
            totalAmount: order.totalAmount,
            taxAmount: Value(order.taxAmount),
            discountAmount: Value(order.discountAmount),
            createdAt: order.createdAt,
            paymentMethod: Value(order.paymentMethod),
            paymentStatus: Value(order.paymentStatus),
            customerId: Value(order.customerId),
            isSynced: const Value(false),
          ));

      for (var item in order.items) {
        await _db.into(_db.orderItems).insert(OrderItemsCompanion.insert(
              id: item.id,
              orderId: order.id,
              productId: item.product.id,
              quantity: item.quantity,
              price: item.price,
              taxAmount: Value(item.taxAmount),
              discountAmount: Value(item.discountAmount),
              notes: Value(item.notes),
              modifiers: Value(item.modifiers.isNotEmpty
                  ? jsonEncode(item.modifiers.map((e) => e.toJson()).toList())
                  : null),
            ));
      }
    });
  }

  Future<void> markOrderSynced(String orderId) async {
    await (_db.update(_db.orders)..where((t) => t.id.equals(orderId)))
        .write(const OrdersCompanion(isSynced: Value(true)));
  }

  Future<void> deleteOrder(String orderId) async {
    await (_db.delete(_db.orders)..where((t) => t.id.equals(orderId))).go();
    await (_db.delete(_db.orderItems)..where((t) => t.orderId.equals(orderId)))
        .go();
  }

  Future<List<domain.Order>> getUnsyncedOrders() async {
    final query = _db.select(_db.orders)
      ..where((t) => t.isSynced.equals(false));
    final rows = await query.get();

    final orders = <domain.Order>[];
    for (var row in rows) {
      final itemsQuery = _db.select(_db.orderItems).join([
        innerJoin(
            _db.products, _db.products.id.equalsExp(_db.orderItems.productId))
      ])
        ..where(_db.orderItems.orderId.equals(row.id));

      final itemRows = await itemsQuery.get();

      final items = itemRows.map((r) {
        final item = r.readTable(_db.orderItems);
        final product = r.readTable(_db.products);

        return domain.OrderItem(
          id: item.id,
          quantity: item.quantity,
          price: item.price,
          taxAmount: item.taxAmount,
          discountAmount: item.discountAmount,
          notes: item.notes,
          modifiers: item.modifiers != null
              ? (jsonDecode(item.modifiers!) as List)
                  .map((e) => ModifierItem.fromJson(e))
                  .toList()
              : [],
          product: domain.Product(
            id: product.id,
            categoryId: product.categoryId,
            nameEn: product.nameEn,
            nameAr: product.nameAr,
            price: product.price,
            isAvailable: product.isAvailable,
            modifierGroups: product.modifierGroups != null
                ? (jsonDecode(product.modifierGroups!) as List)
                    .map((e) => ModifierGroup.fromJson(e))
                    .toList()
                : [],
          ),
        );
      }).toList();

      orders.add(domain.Order(
        id: row.id,
        status: parseOrderStatus(row.status),
        paymentMethod: row.paymentMethod,
        paymentStatus: row.paymentStatus,
        customerId: row.customerId,
        totalAmount: row.totalAmount,
        taxAmount: row.taxAmount,
        discountAmount: row.discountAmount,
        createdAt: row.createdAt,
        items: items,
      ));
    }
    return orders;
  }
}
