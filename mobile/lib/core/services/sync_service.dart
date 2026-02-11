import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../data/repositories/shifts_repository_impl.dart';
import '../../presentation/features/auth/auth_controller.dart';

import '../../data/repositories/customers_repository_impl.dart';
import '../../data/repositories/users_repository_impl.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../data/repositories/catalog_repository_impl.dart';

part 'sync_service.g.dart';

@Riverpod(keepAlive: true)
SyncService syncService(SyncServiceRef ref) {
  return SyncService(ref);
}

class SyncService {
  final Ref _ref;
  Timer? _timer;
  bool _isSyncing = false;

  SyncService(this._ref) {
    _listenForLoginAndSync();
    _startSyncTimer();
  }

  void _listenForLoginAndSync() {
    _ref.listen(authControllerProvider, (previous, next) {
      final oldToken = previous?.valueOrNull?.accessToken;
      final newToken = next.valueOrNull?.accessToken;

      final wasLoggedIn = oldToken != null && oldToken.isNotEmpty;
      final isLoggedIn = newToken != null && newToken.isNotEmpty;

      if (!wasLoggedIn && isLoggedIn) {
        unawaited(syncAll());
      }
    });
  }

  void _startSyncTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      syncAll();
    });
  }

  Future<void> syncAll() async {
    if (_isSyncing) return;

    final authState = _ref.read(authControllerProvider);
    final user = authState.value;

    final token = user?.accessToken;
    if (token == null || token.isEmpty) {
      return; // Cannot sync if not logged in
    }

    _isSyncing = true;
    try {
      print('Starting sync...');

      // Sync Catalog first so cashier can see categories/products immediately
      await _ref.read(catalogRepositoryProvider).syncCatalog(token);

      // Sync Orders
      await _ref
          .read(ordersRepositoryProvider)
          .syncPendingOrders(token);

      // Sync Shifts
      await _ref.read(shiftsRepositoryProvider).syncShifts(token);

      // Sync Customers
      await _ref
          .read(customersRepositoryProvider)
          .syncCustomers(token);

      // Sync Users
      await _ref.read(usersRepositoryProvider).syncUsers(token);

      // Sync Inventory (Suppliers & Ingredients & Recipes)
      final inventoryRepo = _ref.read(inventoryRepositoryProvider);
      await inventoryRepo.syncPendingPurchaseOrders(token);
      await inventoryRepo.syncInventory(token);

      print('Sync completed.');
    } catch (e) {
      print('Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  void stop() {
    _timer?.cancel();
  }
}
