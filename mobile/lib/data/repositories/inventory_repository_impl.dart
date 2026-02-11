import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/ingredient.dart' as domain;
import '../../domain/entities/inventory_log.dart' as domain;
import '../../domain/entities/purchase_order.dart' as domain;
import '../../domain/entities/recipe_item.dart' as domain;
import '../../domain/entities/supplier.dart' as domain;
import '../../domain/entities/warehouse.dart' as domain;
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/local/database.dart';
import '../datasources/remote/inventory_remote_datasource.dart';
import '../../presentation/features/auth/auth_controller.dart';

part 'inventory_repository_impl.g.dart';

@riverpod
InventoryRepository inventoryRepository(InventoryRepositoryRef ref) {
  return InventoryRepositoryImpl(
    ref.watch(inventoryRemoteDataSourceProvider),
    ref.watch(appDatabaseProvider),
    ref,
  );
}

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource _remoteDataSource;
  final AppDatabase _db;
  final InventoryRepositoryRef _ref;
  final Uuid _uuid = const Uuid();

  InventoryRepositoryImpl(this._remoteDataSource, this._db, this._ref);

  String? get _token => _ref.read(authControllerProvider).value?.accessToken;

  double _toDouble(dynamic value, {double fallback = 0}) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  Map<String, dynamic> _normalizeIngredientJson(Map<String, dynamic> json) {
    final stockList = json['stock'] is List
        ? (json['stock'] as List).whereType<Map>().map((item) {
            final stockItem = Map<String, dynamic>.from(item);
            return {
              ...stockItem,
              'quantity': _toDouble(stockItem['quantity']),
              'minLevel': _toDouble(stockItem['minLevel']),
            };
          }).toList(growable: false)
        : const <Map<String, dynamic>>[];

    final currentStock = json['stock'] is List
        ? stockList.fold<double>(
            0,
            (sum, item) => sum + _toDouble(item['quantity']),
          )
        : _toDouble(json['currentStock']);

    return {
      ...json,
      'currentStock': currentStock,
      'minLevel': _toDouble(json['minLevel']),
      'costPerUnit': _toDouble(json['costPerUnit']),
      'stock': stockList,
    };
  }

  Map<String, dynamic> _normalizePurchaseOrderJson(Map<String, dynamic> json) {
    final items = json['items'] is List
        ? (json['items'] as List).whereType<Map>().map((rawItem) {
            final item = Map<String, dynamic>.from(rawItem);
            final ingredientRaw = item['ingredient'];
            final ingredient = ingredientRaw is Map
                ? _normalizeIngredientJson(
                    Map<String, dynamic>.from(ingredientRaw),
                  )
                : ingredientRaw;
            return {
              ...item,
              'ingredient': ingredient,
              'quantity': _toDouble(item['quantity']),
              'unitPrice': _toDouble(item['unitPrice']),
              'totalPrice': _toDouble(item['totalPrice']),
            };
          }).toList(growable: false)
        : const <Map<String, dynamic>>[];

    return {
      ...json,
      'totalAmount': _toDouble(json['totalAmount']),
      'items': items,
    };
  }

  Map<String, dynamic> _normalizeRecipeItemJson(Map<String, dynamic> json) {
    final ingredientRaw = json['ingredient'];
    final ingredient = ingredientRaw is Map
        ? _normalizeIngredientJson(Map<String, dynamic>.from(ingredientRaw))
        : ingredientRaw;
    return {
      ...json,
      'ingredient': ingredient,
      'quantity': _toDouble(json['quantity']),
    };
  }

  @override
  Future<List<domain.Warehouse>> getWarehouses() async {
    final token = _token;
    if (token != null) {
      final data = await _remoteDataSource.getWarehouses(token);
      final warehouses = data
          .map((json) =>
              domain.Warehouse.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      await _db.batch((batch) {
        for (final w in warehouses) {
          batch.insert(
            _db.warehouses,
            WarehousesCompanion(
              id: Value(w.id),
              name: Value(w.name),
              address: Value(w.address),
              isMain: Value(w.isMain),
              isSynced: const Value(true),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
      return warehouses;
    }

    final localData = await _db.select(_db.warehouses).get();
    return localData
        .map(
          (w) => domain.Warehouse(
            id: w.id,
            name: w.name,
            address: w.address,
            isMain: w.isMain,
          ),
        )
        .toList();
  }

  @override
  Future<List<domain.Supplier>> getSuppliers() async {
    final token = _token;
    if (token != null) {
      final data = await _remoteDataSource.getSuppliers(token);
      final suppliers = data
          .map((json) =>
              domain.Supplier.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      await _db.batch((batch) {
        for (final s in suppliers) {
          batch.insert(
            _db.suppliers,
            SuppliersCompanion(
              id: Value(s.id),
              name: Value(s.name),
              contactPerson: Value(s.contactPerson),
              phone: Value(s.phone),
              email: Value(s.email),
              address: Value(s.address),
              isSynced: const Value(true),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
      return suppliers;
    }

    final localData = await _db.select(_db.suppliers).get();
    return localData
        .map(
          (s) => domain.Supplier(
            id: s.id,
            name: s.name,
            contactPerson: s.contactPerson,
            phone: s.phone,
            email: s.email,
            address: s.address,
            isActive: true,
          ),
        )
        .toList();
  }

  @override
  Future<domain.Supplier> createSupplier(
    String name,
    String? email,
    String? phone,
  ) async {
    final token = _token;
    if (token == null) {
      throw Exception('Not authenticated');
    }
    final data = await _remoteDataSource.createSupplier(token, {
      'name': name,
      'email': email,
      'phone': phone,
    });
    return domain.Supplier.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<List<domain.Ingredient>> getIngredients() async {
    final token = _token;
    if (token != null) {
      final data = await _remoteDataSource.getIngredients(token);
      final ingredients = <domain.Ingredient>[];

      await _db.batch((batch) {
        for (final raw in data) {
          final json = _normalizeIngredientJson(Map<String, dynamic>.from(raw));
          final ingredient = domain.Ingredient.fromJson(json);
          ingredients.add(ingredient);

          batch.insert(
            _db.ingredients,
            IngredientsCompanion(
              id: Value(ingredient.id),
              name: Value(ingredient.name),
              unit: Value(ingredient.unit),
              currentStock: Value(ingredient.currentStock),
              minLevel: Value(ingredient.minLevel),
              costPerUnit: Value(ingredient.costPerUnit),
              isSynced: const Value(true),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });

      return ingredients;
    }

    final localData = await _db.select(_db.ingredients).get();
    return localData
        .map(
          (i) => domain.Ingredient(
            id: i.id,
            name: i.name,
            unit: i.unit,
            currentStock: i.currentStock,
            minLevel: i.minLevel,
            costPerUnit: i.costPerUnit,
          ),
        )
        .toList();
  }

  @override
  Future<domain.Ingredient> createIngredient(String name, String unit) async {
    final token = _token;
    if (token == null) {
      throw Exception('Not authenticated');
    }
    final data = await _remoteDataSource.createIngredient(token, {
      'name': name,
      'unit': unit,
    });
    return domain.Ingredient.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> updateStock(
    String ingredientId,
    double change, {
    String? warehouseId,
    String? reason,
    String? notes,
  }) async {
    final token = _token;
    if (token == null) {
      throw Exception('Not authenticated');
    }

    await _remoteDataSource.updateStock(
      token,
      ingredientId,
      change,
      warehouseId: warehouseId,
      reason: reason,
      notes: notes,
    );

    final ingredient = await (_db.select(_db.ingredients)
          ..where((t) => t.id.equals(ingredientId)))
        .getSingleOrNull();
    if (ingredient != null) {
      final newStock = ingredient.currentStock + change;
      await _db.update(_db.ingredients).replace(
            ingredient.copyWith(currentStock: newStock),
          );

      await _db.into(_db.inventoryLogs).insert(
            InventoryLogsCompanion.insert(
              id: _uuid.v4(),
              ingredientId: ingredientId,
              ingredientName: Value(ingredient.name),
              warehouseId: Value(warehouseId),
              warehouseName: const Value(null),
              quantityChange: change,
              oldQuantity: Value(ingredient.currentStock),
              newQuantity: Value(newStock),
              reason: reason ?? 'ADJUSTMENT',
              notes: Value(notes),
              createdAt: DateTime.now(),
              isSynced: const Value(true),
            ),
          );
    }
  }

  @override
  Future<List<domain.InventoryLog>> getInventoryLogs() async {
    final token = _token;
    if (token != null) {
      final data = await _remoteDataSource.getInventoryLogs(token);
      final logs = data.map((json) {
        final raw = Map<String, dynamic>.from(json);
        return domain.InventoryLog(
          id: raw['id']?.toString() ?? '',
          ingredientId: raw['ingredient'] is Map
              ? raw['ingredient']['id']?.toString() ?? ''
              : raw['ingredientId']?.toString() ?? '',
          ingredientName: raw['ingredient'] is Map
              ? raw['ingredient']['name']?.toString()
              : raw['ingredientName']?.toString(),
          warehouseId: raw['warehouse'] is Map
              ? raw['warehouse']['id']?.toString()
              : raw['warehouseId']?.toString(),
          warehouseName: raw['warehouse'] is Map
              ? raw['warehouse']['name']?.toString()
              : raw['warehouseName']?.toString(),
          quantityChange: _toDouble(raw['quantityChange']),
          oldQuantity:
              raw['oldQuantity'] == null ? null : _toDouble(raw['oldQuantity']),
          newQuantity:
              raw['newQuantity'] == null ? null : _toDouble(raw['newQuantity']),
          reason: raw['reason']?.toString() ?? 'ADJUSTMENT',
          notes: raw['notes']?.toString(),
          referenceId: raw['referenceId']?.toString(),
          createdAt: DateTime.tryParse(raw['createdAt']?.toString() ?? '') ??
              DateTime.now(),
        );
      }).toList(growable: false);

      await _db.batch((batch) {
        for (final log in logs) {
          batch.insert(
            _db.inventoryLogs,
            InventoryLogsCompanion(
              id: Value(log.id),
              ingredientId: Value(log.ingredientId),
              ingredientName: Value(log.ingredientName),
              warehouseId: Value(log.warehouseId),
              warehouseName: Value(log.warehouseName),
              quantityChange: Value(log.quantityChange),
              oldQuantity: Value(log.oldQuantity),
              newQuantity: Value(log.newQuantity),
              reason: Value(log.reason),
              notes: Value(log.notes),
              referenceId: Value(log.referenceId),
              createdAt: Value(log.createdAt),
              isSynced: const Value(true),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });

      return logs;
    }

    final local = await (_db.select(_db.inventoryLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return local
        .map(
          (log) => domain.InventoryLog(
            id: log.id,
            ingredientId: log.ingredientId,
            ingredientName: log.ingredientName,
            warehouseId: log.warehouseId,
            warehouseName: log.warehouseName,
            quantityChange: log.quantityChange,
            oldQuantity: log.oldQuantity,
            newQuantity: log.newQuantity,
            reason: log.reason,
            notes: log.notes,
            referenceId: log.referenceId,
            createdAt: log.createdAt,
          ),
        )
        .toList();
  }

  @override
  Future<List<domain.PurchaseOrder>> getPurchaseOrders() async {
    final token = _token;
    if (token != null) {
      final data = await _remoteDataSource.getPurchaseOrders(token);
      final orders = data
          .map((json) => domain.PurchaseOrder.fromJson(
              _normalizePurchaseOrderJson(Map<String, dynamic>.from(json))))
          .toList();

      await _db.batch((batch) {
        for (final po in orders) {
          batch.insert(
            _db.purchaseOrders,
            PurchaseOrdersCompanion(
              id: Value(po.id),
              supplierId: Value(po.supplierId),
              status: Value(po.status),
              totalCost: Value(po.totalAmount),
              createdAt:
                  Value(DateTime.tryParse(po.createdAt) ?? DateTime.now()),
              expectedDelivery: Value(po.expectedDeliveryDate != null
                  ? DateTime.tryParse(po.expectedDeliveryDate!)
                  : null),
              notes: Value(po.notes),
              paymentDueDate: Value(po.paymentDueDate != null
                  ? DateTime.tryParse(po.paymentDueDate!)
                  : null),
              isSynced: const Value(true),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });

      return orders;
    }

    final local = await _db.select(_db.purchaseOrders).get();
    return local
        .map(
          (po) => domain.PurchaseOrder(
            id: po.id,
            supplierId: po.supplierId,
            status: po.status,
            totalAmount: po.totalCost,
            createdAt: po.createdAt.toIso8601String(),
            expectedDeliveryDate: po.expectedDelivery?.toIso8601String(),
            paymentDueDate: po.paymentDueDate?.toIso8601String(),
            notes: po.notes,
            items: const [],
          ),
        )
        .toList();
  }

  @override
  Future<domain.PurchaseOrder> createPurchaseOrder(
    String supplierId,
    String? notes,
  ) async {
    final token = _token;
    if (token != null) {
      final data = await _remoteDataSource.createPurchaseOrder(token, {
        'supplierId': supplierId,
        'notes': notes,
      });
      return domain.PurchaseOrder.fromJson(
          _normalizePurchaseOrderJson(Map<String, dynamic>.from(data)));
    }

    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.into(_db.purchaseOrders).insert(
          PurchaseOrdersCompanion.insert(
            id: id,
            supplierId: supplierId,
            status: 'draft',
            totalCost: const Value(0),
            createdAt: now,
            notes: Value(notes),
            isSynced: const Value(false),
          ),
        );

    return domain.PurchaseOrder(
      id: id,
      supplierId: supplierId,
      status: 'draft',
      totalAmount: 0,
      createdAt: now.toIso8601String(),
      notes: notes,
      items: const [],
    );
  }

  @override
  Future<domain.PurchaseOrder> addPOItem(
    String poId,
    String ingredientId,
    double quantity,
    double unitPrice,
  ) async {
    final token = _token;
    if (token == null) {
      throw Exception('Not authenticated');
    }
    final data = await _remoteDataSource.addPOItem(token, poId, {
      'ingredientId': ingredientId,
      'quantity': quantity,
      'unitPrice': unitPrice,
    });
    return domain.PurchaseOrder.fromJson(
        _normalizePurchaseOrderJson(Map<String, dynamic>.from(data)));
  }

  @override
  Future<domain.PurchaseOrder> receivePO(String poId) async {
    final token = _token;
    if (token == null) {
      throw Exception('Not authenticated');
    }
    final data =
        await _remoteDataSource.updatePOStatus(token, poId, 'received');
    return domain.PurchaseOrder.fromJson(
        _normalizePurchaseOrderJson(Map<String, dynamic>.from(data)));
  }

  @override
  Future<List<domain.RecipeItem>> getProductRecipe(String productId) async {
    final token = _token;
    if (token == null) {
      return [];
    }
    final data = await _remoteDataSource.getProductRecipe(token, productId);
    return data
        .map((json) => domain.RecipeItem.fromJson(
            _normalizeRecipeItemJson(Map<String, dynamic>.from(json))))
        .toList();
  }

  @override
  Future<List<domain.RecipeItem>> getModifierRecipe(String modifierId) async {
    final token = _token;
    if (token == null) {
      return [];
    }
    final data = await _remoteDataSource.getModifierRecipe(token, modifierId);
    return data
        .map((json) => domain.RecipeItem.fromJson(
            _normalizeRecipeItemJson(Map<String, dynamic>.from(json))))
        .toList();
  }

  @override
  Future<domain.RecipeItem> addRecipeItem(
    String productId,
    String ingredientId,
    double quantity,
  ) async {
    final token = _token;
    if (token == null) {
      throw Exception('Not authenticated');
    }
    final data = await _remoteDataSource.addRecipeItem(token, {
      'productId': productId,
      'ingredientId': ingredientId,
      'quantity': quantity,
    });
    return domain.RecipeItem.fromJson(
        _normalizeRecipeItemJson(Map<String, dynamic>.from(data)));
  }

  @override
  Future<domain.RecipeItem> addModifierRecipeItem(
    String modifierId,
    String ingredientId,
    double quantity,
  ) async {
    final token = _token;
    if (token == null) {
      throw Exception('Not authenticated');
    }
    final data = await _remoteDataSource.addModifierRecipeItem(token, {
      'modifierId': modifierId,
      'ingredientId': ingredientId,
      'quantity': quantity,
    });
    return domain.RecipeItem.fromJson(
        _normalizeRecipeItemJson(Map<String, dynamic>.from(data)));
  }

  @override
  Future<void> syncInventory(String token) async {
    await getIngredients();
    await getSuppliers();
    await getPurchaseOrders();
  }

  @override
  Future<void> syncPendingPurchaseOrders(String token) async {
    final pending = await (_db.select(_db.purchaseOrders)
          ..where((t) => t.isSynced.equals(false)))
        .get();

    for (final po in pending) {
      final created = await _remoteDataSource.createPurchaseOrder(token, {
        'supplierId': po.supplierId,
        'notes': po.notes,
      });
      final remoteId = created['id'] as String?;
      if (remoteId != null) {
        await (_db.update(_db.purchaseOrders)..where((t) => t.id.equals(po.id)))
            .write(
          PurchaseOrdersCompanion(
            id: Value(remoteId),
            isSynced: const Value(true),
          ),
        );
      }
    }
  }
}
