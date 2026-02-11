import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../data/repositories/shifts_repository_impl.dart';
import '../../presentation/features/auth/auth_controller.dart';

import '../../data/repositories/customers_repository_impl.dart';
import '../../data/repositories/users_repository_impl.dart';
import '../../domain/repositories/inventory_repository.dart';

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
    _startSyncTimer();
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

    if (user == null || user.accessToken.isEmpty) {
      return; // Cannot sync if not logged in
    }

    _isSyncing = true;
    try {
      print('Starting sync...');

      // Sync Orders
      await _ref
          .read(ordersRepositoryProvider)
          .syncPendingOrders(user.accessToken);

      // Sync Shifts
      await _ref.read(shiftsRepositoryProvider).syncShifts(user.accessToken);

      // Sync Customers
      await _ref
          .read(customersRepositoryProvider)
          .syncCustomers(user.accessToken);

      // Sync Users
      await _ref.read(usersRepositoryProvider).syncUsers(user.accessToken);

      // Sync Inventory (Suppliers & Ingredients & Recipes)
      final inventoryRepo = _ref.read(inventoryRepositoryProvider);
      await inventoryRepo.syncPendingPurchaseOrders(user.accessToken);
      await inventoryRepo.syncInventory(user.accessToken);

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
