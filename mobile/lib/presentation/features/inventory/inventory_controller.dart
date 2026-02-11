import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/supplier.dart';
import '../../../domain/entities/ingredient.dart';
import '../../../domain/entities/purchase_order.dart';
import '../../../domain/entities/warehouse.dart';
import '../../../domain/entities/inventory_log.dart';
import '../../../data/repositories/inventory_repository_impl.dart';

part 'inventory_controller.g.dart';

@riverpod
Future<List<Warehouse>> warehouses(WarehousesRef ref) {
  return ref.watch(inventoryRepositoryProvider).getWarehouses();
}

@riverpod
Future<List<InventoryLog>> inventoryLogs(InventoryLogsRef ref) {
  return ref.watch(inventoryRepositoryProvider).getInventoryLogs();
}

@riverpod
class SuppliersController extends _$SuppliersController {
  @override
  FutureOr<List<Supplier>> build() {
    return ref.read(inventoryRepositoryProvider).getSuppliers();
  }

  Future<void> addSupplier(String name, String? email, String? phone) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(inventoryRepositoryProvider)
          .createSupplier(name, email, phone);
      return ref.read(inventoryRepositoryProvider).getSuppliers();
    });
  }
}

@riverpod
class IngredientsController extends _$IngredientsController {
  @override
  FutureOr<List<Ingredient>> build() {
    return ref.read(inventoryRepositoryProvider).getIngredients();
  }

  Future<void> addIngredient(String name, String unit) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(inventoryRepositoryProvider).createIngredient(name, unit);
      return ref.read(inventoryRepositoryProvider).getIngredients();
    });
  }

  Future<void> updateStock(String ingredientId, double change,
      {String? warehouseId, String? reason, String? notes}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(inventoryRepositoryProvider).updateStock(
          ingredientId, change,
          warehouseId: warehouseId, reason: reason, notes: notes);
      return ref.read(inventoryRepositoryProvider).getIngredients();
    });
  }
}

@riverpod
class PurchaseOrdersController extends _$PurchaseOrdersController {
  @override
  FutureOr<List<PurchaseOrder>> build() {
    return ref.read(inventoryRepositoryProvider).getPurchaseOrders();
  }

  Future<void> createPO(String supplierId, String? notes) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(inventoryRepositoryProvider)
          .createPurchaseOrder(supplierId, notes);
      return ref.read(inventoryRepositoryProvider).getPurchaseOrders();
    });
  }

  Future<void> addPOItem(String poId, String ingredientId, double quantity,
      double unitPrice) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(inventoryRepositoryProvider)
          .addPOItem(poId, ingredientId, quantity, unitPrice);
      return ref.read(inventoryRepositoryProvider).getPurchaseOrders();
    });
  }

  Future<void> receivePO(String poId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(inventoryRepositoryProvider).receivePO(poId);
      // Refresh ingredients as stock changed
      ref.invalidate(ingredientsControllerProvider);
      return ref.read(inventoryRepositoryProvider).getPurchaseOrders();
    });
  }
}
