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
  RestaurantTables,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {},
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pos.sqlite'));
    return NativeDatabase(file);
  });
}
