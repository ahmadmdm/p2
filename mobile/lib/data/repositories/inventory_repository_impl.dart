import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/recipe_item.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/remote/inventory_remote_datasource.dart';
import '../datasources/local/database.dart';
import '../../presentation/features/auth/auth_controller.dart';

import '../../domain/entities/warehouse.dart';
import '../../domain/entities/inventory_log.dart';

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
  final _uuid = const Uuid();

  InventoryRepositoryImpl(this._remoteDataSource, this._db, this._ref);

  String? get _token => _ref.read(authControllerProvider).value?.accessToken;

  @override
  Future<List<Warehouse>> getWarehouses() async {
    if (_token != null) {
      try {
        final data = await _remoteDataSource.getWarehouses(_token!);
        final warehouses =
            data.map((json) => Warehouse.fromJson(json)).toList();

        await _db.batch((batch) {
          for (final w in warehouses) {
            batch.insertOnConflictUpdate(
              _db.warehouses,
              WarehousesCompanion(
                id: Value(w.id),
                name: Value(w.name),
                address: Value(w.address),
                isMain: Value(w.isMain),
              ),
            );
          }
        });
        return warehouses;
      } catch (e) {
        print('Error fetching warehouses: $e');
      }
    }

    final localData = await _db.select(_db.warehouses).get();
    return localData
        .map((w) => Warehouse(
              id: w.id,
              name: w.name,
              address: w.address,
              isMain: w.isMain,
            ))
        .toList();
  }

  @override
  Future<List<Supplier>> getSuppliers() async {
    if (_token != null) {
      try {
        final data = await _remoteDataSource.getSuppliers(_token!);
        final suppliers = data.map((json) => Supplier.fromJson(json)).toList();

        // Cache to DB
        await _db.batch((batch) {
          for (final s in suppliers) {
            batch.insertOnConflictUpdate(
              _db.suppliers,
              SuppliersCompanion(
                id: Value(s.id),
                name: Value(s.name),
                email: Value(s.email),
                phone: Value(s.phone),
                contactPerson: Value(s.contactPerson),
                address: Value(s.address),
              ),
            );
          }
        });
        return suppliers;
      } catch (e) {
        // Fallback to local
        print('Error fetching suppliers: $e');
      }
    }

    final localData = await _db.select(_db.suppliers).get();
    return localData
        .map((s) => Supplier(
              id: s.id,
              name: s.name,
              email: s.email,
              phone: s.phone,
              contactPerson: s.contactPerson,
              address: s.address,
            ))
        .toList();
  }

  @override
  Future<Supplier> createSupplier(
      String name, String? email, String? phone) async {
    if (_token == null) throw Exception('Not authenticated');
    final data = await _remoteDataSource.createSupplier(_token!, {
      'name': name,
      'email': email,
      'phone': phone,
    });
    // Sync will handle saving to DB later, or we can add it here.
    return Supplier.fromJson(data);
  }

  @override
  Future<List<Ingredient>> getIngredients() async {
    if (_token != null) {
      try {
        final data = await _remoteDataSource.getIngredients(_token!);
        final ingredients = <Ingredient>[];

        await _db.batch((batch) {
          for (final json in data) {
            final i = Ingredient.fromJson(json);
            ingredients.add(i);

            // Calculate total stock if not provided in root
            double totalStock = i.currentStock;
            if (json['stock'] != null && json['stock'] is List) {
              totalStock = (json['stock'] as List).fold(
                  0.0,
                  (sum, item) =>
                      sum + ((item['quantity'] as num?)?.toDouble() ?? 0));
            }

            batch.insertOnConflictUpdate(
              _db.ingredients,
              IngredientsCompanion(
                id: Value(i.id),
                name: Value(i.name),
                unit: Value(i.unit),
                currentStock: Value(totalStock),
                minLevel: Value(i.minLevel),
                costPerUnit: Value(i.costPerUnit),
              ),
            );

            // Process Stock & Warehouses
            if (json['stock'] != null && json['stock'] is List) {
              final stockList = json['stock'] as List;
              for (final s in stockList) {
                final warehouse = s['warehouse'];
                if (warehouse != null) {
                  batch.insertOnConflictUpdate(
                    _db.warehouses,
                    WarehousesCompanion(
                      id: Value(warehouse['id']),
                      name: Value(warehouse['name']),
                      address: Value(warehouse['address']),
                      isMain: Value(warehouse['isMain'] ?? false),
                    ),
                  );

                  batch.insertOnConflictUpdate(
                    _db.inventoryItems,
                    InventoryItemsCompanion(
                      id: Value(s['id']),
                      ingredientId: Value(i.id),
                      warehouseId: Value(warehouse['id']),
                      quantity: Value((s['quantity'] as num).toDouble()),
                      minLevel: Value((s['minLevel'] as num?)?.toDouble() ?? 0),
                    ),
                  );
                }
              }
            }
          }
        });
        return ingredients;
      } catch (e) {
        print('Error fetching ingredients: $e');
      }
    }

    final localData = await _db.select(_db.ingredients).get();
    // Ideally we should also fetch stock items and attach them to Ingredient
    // But Ingredient entity in local fetch logic below doesn't populate stock list yet.
    // For now, we return basic ingredient info.

    return localData
        .map((i) => Ingredient(
              id: i.id,
              name: i.name,
              unit: i.unit,
              currentStock: i.currentStock,
              minLevel: i.minLevel,
              costPerUnit: i.costPerUnit,
            ))
        .toList();
  }

  @override
  Future<Ingredient> createIngredient(String name, String unit) async {
    if (_token == null) throw Exception('Not authenticated');
    final data = await _remoteDataSource.createIngredient(_token!, {
      'name': name,
      'unit': unit,
    });
    return Ingredient.fromJson(data);
  }

  @override
  Future<void> updateStock(String ingredientId, double change,
      {String? warehouseId, String? reason, String? notes}) async {
    if (_token == null) throw Exception('Not authenticated');

    // 1. Remote update
    await _remoteDataSource.updateStock(_token!, ingredientId, change,
        warehouseId: warehouseId, reason: reason, notes: notes);

    // 2. Fetch details for logging
    final ingredient = await (_db.select(_db.ingredients)
          ..where((tbl) => tbl.id.equals(ingredientId)))
        .getSingleOrNull();

    String? warehouseName;
    if (warehouseId != null) {
      final w = await (_db.select(_db.warehouses)
            ..where((tbl) => tbl.id.equals(warehouseId)))
          .getSingleOrNull();
      warehouseName = w?.name;
    }

    final oldStock = ingredient?.currentStock ?? 0;
    final newStock = oldStock + change;

    // 3. Update local DB (Optimistic / Sync)
    await _db.batch((batch) {
      // Update InventoryItem
      if (warehouseId != null) {
        batch.customStatement(
          'UPDATE inventory_items SET quantity = quantity + ? WHERE ingredient_id = ? AND warehouse_id = ?',
          [change, ingredientId, warehouseId],
        );
      }

      // Update Ingredient total stock
      if (ingredient != null) {
        batch.update(_db.ingredients).replace(
              ingredient.copyWith(currentStock: newStock),
            );
      }

      // Insert Log
      if (ingredient != null) {
        batch.insert(
          _db.inventoryLogs,
          InventoryLogsCompanion(
            id: Value(_uuid.v4()),
            ingredientId: Value(ingredientId),
            ingredientName: Value(ingredient.name),
            warehouseId: Value(warehouseId),
            warehouseName: Value(warehouseName),
            quantityChange: Value(change),
            oldQuantity: Value(oldStock),
            newQuantity: Value(newStock),
            reason: Value(reason ?? 'ADJUSTMENT'),
            notes: Value(notes),
            createdAt: Value(DateTime.now()),
            isSynced: const Value(true), // Since remote succeeded
          ),
        );
      }
    });
  }

  @override
  Future<List<InventoryLog>> getInventoryLogs() async {
    if (_token != null) {
      try {
        final data = await _remoteDataSource.getInventoryLogs(_token!);
        final logs = data.map((json) => InventoryLog.fromJson(json)).toList();

        await _db.batch((batch) {
          for (final log in logs) {
            batch.insertOnConflictUpdate(
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
            );
          }
        });
        return logs;
      } catch (e) {
        print('Error fetching inventory logs: $e');
      }
    }

    // Fallback to local
    final localData = await (_db.select(_db.inventoryLogs)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .get();

    return localData
        .map((log) => InventoryLog(
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
            ))
        .toList();
  }

  @override
  Future<List<PurchaseOrder>> getPurchaseOrders() async {
    if (_token != null) {
      try {
        final data = await _remoteDataSource.getPurchaseOrders(_token!);
        final pos = data.map((json) => PurchaseOrder.fromJson(json)).toList();

        await _db.batch((batch) {
          for (final po in pos) {
            batch.insertOnConflictUpdate(
              _db.purchaseOrders,
              PurchaseOrdersCompanion(
                id: Value(po.id),
                supplierId: Value(po.supplierId),
                status: Value(po.status),
                totalCost: Value(po.totalAmount),
                createdAt: Value(DateTime.parse(po.createdAt)),
                expectedDelivery: Value(po.expectedDeliveryDate != null
                    ? DateTime.parse(po.expectedDeliveryDate!)
                    : null),
                notes: Value(po.notes),
                paymentDueDate: Value(po.paymentDueDate != null
                    ? DateTime.parse(po.paymentDueDate!)
                    : null),
              ),
            );

            batch.deleteWhere(_db.purchaseOrderItems,
                (tbl) => tbl.purchaseOrderId.equals(po.id));

            for (final item in po.items) {
              batch.insert(
                  _db.purchaseOrderItems,
                  PurchaseOrderItemsCompanion.insert(
                    id: item.id,
                    purchaseOrderId: po.id,
                    ingredientId: item.ingredientId,
                    quantity: item.quantity,
                    unitPrice: item.unitPrice,
                  ));
            }
          }
        });
        return pos;
      } catch (e) {
        print('Remote PO fetch failed: $e');
      }
    }

    final localPOs = await _db.select(_db.purchaseOrders).get();
    final List<PurchaseOrder> result = [];

    for (final po in localPOs) {
      final itemsRows = await (_db.select(_db.purchaseOrderItems)
            ..where((t) => t.purchaseOrderId.equals(po.id)))
          .get();
      final supplier = await (_db.select(_db.suppliers)
            ..where((t) => t.id.equals(po.supplierId)))
          .getSingleOrNull();

      final items = <PurchaseOrderItem>[];
      for (final row in itemsRows) {
        final ingredient = await (_db.select(_db.ingredients)
              ..where((t) => t.id.equals(row.ingredientId)))
            .getSingleOrNull();
        items.add(PurchaseOrderItem(
          id: row.id,
          ingredientId: row.ingredientId,
          ingredient: ingredient != null
              ? Ingredient(
                  id: ingredient.id,
                  name: ingredient.name,
                  unit: ingredient.unit,
                  currentStock: ingredient.currentStock,
                  minLevel: ingredient.minLevel,
                  costPerUnit: ingredient.costPerUnit,
                )
              : null,
          quantity: row.quantity,
          unitPrice: row.unitPrice,
          totalPrice: row.quantity * row.unitPrice,
        ));
      }

      result.add(PurchaseOrder(
        id: po.id,
        supplierId: po.supplierId,
        supplier: supplier != null
            ? Supplier(
                id: supplier.id,
                name: supplier.name,
                email: supplier.email,
                phone: supplier.phone,
                contactPerson: supplier.contactPerson,
                address: supplier.address)
            : null,
        status: po.status,
        totalAmount: po.totalCost,
        createdAt: po.createdAt.toIso8601String(),
        expectedDeliveryDate: po.expectedDelivery?.toIso8601String(),
        notes: po.notes,
        paymentDueDate: po.paymentDueDate?.toIso8601String(),
        items: items,
      ));
    }
    return result;
  }

  @override
  Future<PurchaseOrder> createPurchaseOrder(
      String supplierId, String? notes) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    // Save locally
    await _db.into(_db.purchaseOrders).insert(PurchaseOrdersCompanion.insert(
          id: id,
          supplierId: supplierId,
          status: 'draft',
          createdAt: now,
          notes: Value(notes),
          isSynced: const Value(false),
        ));

    // Return local object immediately
    final supplier = await (_db.select(_db.suppliers)
          ..where((t) => t.id.equals(supplierId)))
        .getSingleOrNull();

    return PurchaseOrder(
      id: id,
      supplierId: supplierId,
      supplier: supplier != null
          ? Supplier(
              id: supplier.id,
              name: supplier.name,
              email: supplier.email,
              phone: supplier.phone,
              contactPerson: supplier.contactPerson,
              address: supplier.address)
          : null,
      status: 'draft',
      totalAmount: 0,
      createdAt: now.toIso8601String(),
      notes: notes,
    );
  }

  @override
  Future<PurchaseOrder> addPOItem(String poId, String ingredientId,
      double quantity, double unitPrice) async {
    if (_token == null) throw Exception('Not authenticated');
    final data = await _remoteDataSource.addPOItem(_token!, poId, {
      'ingredientId': ingredientId,
      'quantity': quantity,
      'unitPrice': unitPrice,
    });
    return PurchaseOrder.fromJson(data);
  }

  @override
  Future<PurchaseOrder> receivePO(String poId) async {
    if (_token == null) throw Exception('Not authenticated');

    final data =
        await _remoteDataSource.updatePOStatus(_token!, poId, 'received');
    final updatedPO = PurchaseOrder.fromJson(data);

    // Update local DB
    await _db.transaction(() async {
      // Update PO status
      await (_db.update(_db.purchaseOrders)..where((t) => t.id.equals(poId)))
          .write(const PurchaseOrdersCompanion(status: Value('received')));

      // Update Stock for each item
      final items = await (_db.select(_db.purchaseOrderItems)
            ..where((t) => t.purchaseOrderId.equals(poId)))
          .get();

      for (final item in items) {
        final ingredient = await (_db.select(_db.ingredients)
              ..where((t) => t.id.equals(item.ingredientId)))
            .getSingleOrNull();

        if (ingredient != null) {
          final newStock = (ingredient.currentStock ?? 0) + item.quantity;
          await _db
              .update(_db.ingredients)
              .replace(ingredient.copyWith(currentStock: newStock));
        }
      }
    });

    return updatedPO;
  }

  @override
  Future<List<RecipeItem>> getProductRecipe(String productId) async {
    if (_token != null) {
      try {
        final data =
            await _remoteDataSource.getProductRecipe(_token!, productId);
        final recipes = data.map((json) {
          final mapped = Map<String, dynamic>.from(json);
          if (json['product'] is Map) {
            mapped['productId'] = json['product']['id'];
          }
          return RecipeItem.fromJson(mapped);
        }).toList();

        // Cache
        await _db.batch((batch) {
          // Delete existing for this product to avoid duplicates
          batch.deleteWhere(
              _db.recipeItems, (tbl) => tbl.productId.equals(productId));

          for (final r in recipes) {
            batch.insertOnConflictUpdate(
              _db.recipeItems,
              RecipeItemsCompanion(
                id: Value(r.id),
                productId: Value(productId),
                ingredientId: Value(r.ingredient.id),
                quantity: Value(r.quantity),
              ),
            );
          }
        });
        return recipes;
      } catch (e) {
        print('Error fetching product recipe: $e');
      }
    }

    // Local
    final query = _db.select(_db.recipeItems).join([
      innerJoin(_db.ingredients,
          _db.ingredients.id.equalsExp(_db.recipeItems.ingredientId))
    ]);
    query.where(_db.recipeItems.productId.equals(productId));

    final rows = await query.get();
    return rows.map((row) {
      final recipe = row.readTable(_db.recipeItems);
      final ingredient = row.readTable(_db.ingredients);
      return RecipeItem(
        id: recipe.id,
        productId: recipe.productId,
        quantity: recipe.quantity,
        ingredient: Ingredient(
          id: ingredient.id,
          name: ingredient.name,
          unit: ingredient.unit,
          currentStock: ingredient.currentStock,
          minLevel: ingredient.minLevel,
          costPerUnit: ingredient.costPerUnit,
        ),
      );
    }).toList();
  }

  @override
  Future<RecipeItem> addRecipeItem(
      String productId, String ingredientId, double quantity) async {
    if (_token == null) throw Exception('Not authenticated');
    final data = await _remoteDataSource.addRecipeItem(_token!, {
      'productId': productId,
      'ingredientId': ingredientId,
      'quantity': quantity,
    });
    return RecipeItem.fromJson(data);
  }

  @override
  Future<List<RecipeItem>> getModifierRecipe(String modifierId) async {
    if (_token != null) {
      try {
        final data =
            await _remoteDataSource.getModifierRecipe(_token!, modifierId);
        final recipes = data.map((json) {
          final mapped = Map<String, dynamic>.from(json);
          if (json['modifierItem'] is Map) {
            mapped['modifierItemId'] = json['modifierItem']['id'];
          }
          return RecipeItem.fromJson(mapped);
        }).toList();

        // Cache
        await _db.batch((batch) {
          batch.deleteWhere(
              _db.recipeItems, (tbl) => tbl.modifierItemId.equals(modifierId));

          for (final r in recipes) {
            batch.insertOnConflictUpdate(
              _db.recipeItems,
              RecipeItemsCompanion(
                id: Value(r.id),
                modifierItemId: Value(modifierId),
                ingredientId: Value(r.ingredient.id),
                quantity: Value(r.quantity),
              ),
            );
          }
        });
        return recipes;
      } catch (e) {
        print('Error fetching modifier recipe: $e');
      }
    }

    // Local
    final query = _db.select(_db.recipeItems).join([
      innerJoin(_db.ingredients,
          _db.ingredients.id.equalsExp(_db.recipeItems.ingredientId))
    ]);
    query.where(_db.recipeItems.modifierItemId.equals(modifierId));

    final rows = await query.get();
    return rows.map((row) {
      final recipe = row.readTable(_db.recipeItems);
      final ingredient = row.readTable(_db.ingredients);
      return RecipeItem(
        id: recipe.id,
        modifierItemId: recipe.modifierItemId,
        quantity: recipe.quantity,
        ingredient: Ingredient(
          id: ingredient.id,
          name: ingredient.name,
          unit: ingredient.unit,
          currentStock: ingredient.currentStock,
          minLevel: ingredient.minLevel,
          costPerUnit: ingredient.costPerUnit,
        ),
      );
    }).toList();
  }

  @override
  Future<RecipeItem> addModifierRecipeItem(
      String modifierId, String ingredientId, double quantity) async {
    if (_token == null) throw Exception('Not authenticated');
    final data = await _remoteDataSource.addModifierRecipeItem(_token!, {
      'modifierId': modifierId,
      'ingredientId': ingredientId,
      'quantity': quantity,
    });
    return RecipeItem.fromJson(data);
  }

  @override
  Future<void> syncInventory(String token) async {
    // 1. Ingredients
    final ingredientsData = await _remoteDataSource.getIngredients(token);
    final ingredients = ingredientsData.map((json) {
      final mapped = Map<String, dynamic>.from(json);
      if (json['stock'] is List && (json['stock'] as List).isNotEmpty) {
        final stockItem = (json['stock'] as List).first;
        mapped['currentStock'] = stockItem['quantity'] is String
            ? double.tryParse(stockItem['quantity']) ?? 0.0
            : (stockItem['quantity'] as num).toDouble();
        mapped['minLevel'] = stockItem['minLevel'] is String
            ? double.tryParse(stockItem['minLevel']) ?? 0.0
            : (stockItem['minLevel'] as num).toDouble();
      }
      return Ingredient.fromJson(mapped);
    }).toList();
    await _db.batch((batch) {
      for (final i in ingredients) {
        batch.insertOnConflictUpdate(
          _db.ingredients,
          IngredientsCompanion(
            id: Value(i.id),
            name: Value(i.name),
            unit: Value(i.unit),
            currentStock: Value(i.currentStock),
            minLevel: Value(i.minLevel),
            costPerUnit: Value(i.costPerUnit),
          ),
        );
      }
    });

    // 2. Suppliers
    final suppliersData = await _remoteDataSource.getSuppliers(token);
    final suppliers =
        suppliersData.map((json) => Supplier.fromJson(json)).toList();
    await _db.batch((batch) {
      for (final s in suppliers) {
        batch.insertOnConflictUpdate(
          _db.suppliers,
          SuppliersCompanion(
            id: Value(s.id),
            name: Value(s.name),
            contactPerson: Value(s.contactPerson),
            email: Value(s.email),
            phone: Value(s.phone),
            address: Value(s.address),
          ),
        );
      }
    });

    // 3. Recipes (All)
    final recipesData = await _remoteDataSource.getAllRecipes(token);
    final recipes = recipesData.map((json) {
      final mapped = Map<String, dynamic>.from(json);
      if (json['product'] is Map) mapped['productId'] = json['product']['id'];
      if (json['modifierItem'] is Map) {
        mapped['modifierItemId'] = json['modifierItem']['id'];
      }
      return RecipeItem.fromJson(mapped);
    }).toList();

    await _db.batch((batch) {
      // We might want to clear old recipes or just upsert. Upsert is safer.
      for (final r in recipes) {
        batch.insertOnConflictUpdate(
          _db.recipeItems,
          RecipeItemsCompanion(
            id: Value(r.id),
            productId: Value(r.productId),
            modifierItemId: Value(r.modifierItemId),
            ingredientId: Value(r.ingredient.id),
            quantity: Value(r.quantity),
          ),
        );
      }
    });

    // 4. Purchase Orders
    try {
      final posData = await _remoteDataSource.getPurchaseOrders(token);
      final pos = posData.map((json) => PurchaseOrder.fromJson(json)).toList();

      await _db.batch((batch) {
        for (final po in pos) {
          batch.insertOnConflictUpdate(
            _db.purchaseOrders,
            PurchaseOrdersCompanion(
              id: Value(po.id),
              supplierId: Value(po.supplierId),
              status: Value(po.status),
              totalCost: Value(po.totalAmount),
              createdAt: Value(DateTime.parse(po.createdAt)),
              expectedDelivery: Value(po.expectedDeliveryDate != null
                  ? DateTime.parse(po.expectedDeliveryDate!)
                  : null),
              notes: Value(po.notes),
              paymentDueDate: Value(po.paymentDueDate != null
                  ? DateTime.parse(po.paymentDueDate!)
                  : null),
            ),
          );

          batch.deleteWhere(_db.purchaseOrderItems,
              (tbl) => tbl.purchaseOrderId.equals(po.id));

          for (final item in po.items) {
            batch.insert(
                _db.purchaseOrderItems,
                PurchaseOrderItemsCompanion.insert(
                  id: item.id,
                  purchaseOrderId: po.id,
                  ingredientId: item.ingredientId,
                  quantity: item.quantity,
                  unitPrice: item.unitPrice,
                ));
          }
        }
      });
    } catch (e) {
      print('Error syncing POs: $e');
    }
  }

  @override
  Future<void> syncPendingPurchaseOrders(String token) async {
    final pending = await (_db.select(_db.purchaseOrders)
          ..where((t) => t.isSynced.equals(false)))
        .get();

    for (final po in pending) {
      try {
        // Create on backend
        final data = await _remoteDataSource.createPurchaseOrder(token, {
          'supplierId': po.supplierId,
          'notes': po.notes,
        });

        final newPO = PurchaseOrder.fromJson(data);

        // Update items to point to new ID
        await _db.customStatement(
            'UPDATE purchase_order_items SET purchase_order_id = ? WHERE purchase_order_id = ?',
            [newPO.id, po.id]);

        await _db.batch((batch) {
          // Delete old PO
          batch.delete(_db.purchaseOrders, po);

          // Insert new PO as synced
          batch.insert(
            _db.purchaseOrders,
            PurchaseOrdersCompanion.insert(
              id: newPO.id,
              supplierId: newPO.supplierId,
              status: newPO.status,
              totalCost: newPO.totalAmount,
              createdAt: DateTime.parse(newPO.createdAt),
              notes: Value(newPO.notes),
              isSynced: const Value(true),
            ),
          );
        });
      } catch (e) {
        print('Error syncing pending PO ${po.id}: $e');
      }
    }
  }
}
