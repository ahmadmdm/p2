import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:io';
import 'tables.dart';

part 'database.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase();
}

@DriftDatabase(tables: [
  Users,
  Categories,
  Products,
  Orders,
  OrderItems,
  Shifts,
  CashTransactions,
  Customers,
  Suppliers,
  Ingredients,
  RecipeItems,
  PurchaseOrders,
  PurchaseOrderItems,
  Warehouses,
  InventoryItems,
  InventoryLogs,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(products, products.modifierGroups);
            await m.addColumn(orderItems, orderItems.modifiers);
            await m.addColumn(orderItems, orderItems.notes);
          }
          if (from < 3) {
            await m.createTable(shifts);
            await m.createTable(cashTransactions);
            await m.addColumn(orders, orders.shiftId);
          }
          if (from < 4) {
            await m.createTable(customers);
          }
          if (from < 5) {
            await m.createTable(suppliers);
            await m.createTable(ingredients);
            await m.createTable(recipeItems);
            await m.createTable(purchaseOrders);
          }
          if (from < 6) {
            await m.addColumn(users, users.pinCode);
          }
          if (from < 7) {
            await m.createTable(purchaseOrderItems);
          }
          if (from < 8) {
            await m.addColumn(purchaseOrders, purchaseOrders.notes);
            await m.addColumn(purchaseOrders, purchaseOrders.paymentDueDate);
          }
          if (from < 9) {
            await m.addColumn(orders, orders.type);
            await m.addColumn(orders, orders.deliveryFee);
            await m.addColumn(orders, orders.deliveryAddress);
            await m.addColumn(orders, orders.driverId);
            await m.addColumn(orders, orders.deliveryProvider);
            await m.addColumn(orders, orders.deliveryReferenceId);
          }
          if (from < 10) {
            await m.addColumn(customers, customers.tier);
          }
          if (from < 11) {
            await m.createTable(warehouses);
            await m.createTable(inventoryItems);
          }
          if (from < 12) {
            await m.createTable(inventoryLogs);
          }
          if (from < 13) {
            await m.addColumn(orders, orders.taxAmount);
            await m.addColumn(orders, orders.discountAmount);
            await m.addColumn(orderItems, orderItems.taxAmount);
            await m.addColumn(orderItems, orderItems.discountAmount);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pos.sqlite'));
    return NativeDatabase(file);
  });
}
