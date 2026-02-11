import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import '../../domain/entities/restaurant_table.dart' as domain;
import '../../domain/repositories/tables_repository.dart';
import '../datasources/remote/tables_remote_datasource.dart';
import '../datasources/local/database.dart';
import '../../presentation/features/auth/auth_controller.dart';

part 'tables_repository_impl.g.dart';

@riverpod
TablesRepository tablesRepository(TablesRepositoryRef ref) {
  return TablesRepositoryImpl(
    ref.watch(tablesRemoteDataSourceProvider),
    ref.watch(appDatabaseProvider),
    ref,
  );
}

class TablesRepositoryImpl implements TablesRepository {
  final TablesRemoteDataSource _remoteDataSource;
  final AppDatabase _db;
  final TablesRepositoryRef _ref;

  TablesRepositoryImpl(this._remoteDataSource, this._db, this._ref);

  @override
  Future<List<domain.RestaurantTable>> getTables() async {
    final user = _ref.read(authControllerProvider).value;
    final token = user?.accessToken;

    if (token != null) {
      try {
        final data = await _remoteDataSource.getTables(token);
        final remoteTables = data
            .map((json) => domain.RestaurantTable.fromJson(json))
            .toList();

        // Cache to local DB
        await _db.batch((batch) {
          for (final table in remoteTables) {
            batch.insert(
              _db.restaurantTables,
              RestaurantTablesCompanion.insert(
                id: table.id,
                tableNumber: table.tableNumber,
                section: Value(table.section),
                capacity: Value(table.capacity),
                x: Value(table.x),
                y: Value(table.y),
                width: Value(table.width),
                height: Value(table.height),
                shape: Value(table.shape),
                rotation: Value(table.rotation),
                status: Value(table.status),
                qrCode: Value(table.qrCode),
                isSynced: const Value(true),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
        return remoteTables;
      } catch (e) {
        print('Remote fetch failed: $e');
      }
    }

    // Local fallback
    final localTables = await _db.select(_db.restaurantTables).get();
    return localTables.map((t) => domain.RestaurantTable(
      id: t.id,
      tableNumber: t.tableNumber,
      section: t.section,
      capacity: t.capacity,
      x: t.x,
      y: t.y,
      width: t.width,
      height: t.height,
      shape: t.shape,
      rotation: t.rotation,
      status: t.status,
      qrCode: t.qrCode,
    )).toList();
  }

  @override
  Future<void> updateLayout(List<domain.RestaurantTable> tables) async {
    // 1. Save locally
    await _db.batch((batch) {
      for (final table in tables) {
        batch.insert(
          _db.restaurantTables,
          RestaurantTablesCompanion.insert(
            id: table.id,
            tableNumber: table.tableNumber,
            section: Value(table.section),
            capacity: Value(table.capacity),
            x: Value(table.x),
            y: Value(table.y),
            width: Value(table.width),
            height: Value(table.height),
            shape: Value(table.shape),
            rotation: Value(table.rotation),
            status: Value(table.status),
            qrCode: Value(table.qrCode),
            isSynced: const Value(false), // Mark as unsynced initially
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    // 2. Try to sync remote
    final user = _ref.read(authControllerProvider).value;
    final token = user?.accessToken;
    if (token != null) {
      try {
        final dtos =
            tables.map((t) => t.toJson()).cast<Map<String, dynamic>>().toList();
        await _remoteDataSource.updateLayout(token, dtos);
        
        // Mark as synced
        // This is a bit inefficient (updates all), but safe for now
        // Or update specific IDs
        await _db.customStatement('UPDATE restaurant_tables SET is_synced = 1');
      } catch (e) {
        print('Layout sync failed: $e');
        // Keep isSynced=false
      }
    }
  }
}
