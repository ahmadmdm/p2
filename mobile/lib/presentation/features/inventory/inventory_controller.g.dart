// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$warehousesHash() => r'27ffe051c4f516870afcb738da50a422fe76c22c';

/// See also [warehouses].
@ProviderFor(warehouses)
final warehousesProvider = AutoDisposeFutureProvider<List<Warehouse>>.internal(
  warehouses,
  name: r'warehousesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$warehousesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WarehousesRef = AutoDisposeFutureProviderRef<List<Warehouse>>;
String _$inventoryLogsHash() => r'ac755cc8bed67ac0dce5e220b4be95042295592f';

/// See also [inventoryLogs].
@ProviderFor(inventoryLogs)
final inventoryLogsProvider =
    AutoDisposeFutureProvider<List<InventoryLog>>.internal(
  inventoryLogs,
  name: r'inventoryLogsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryLogsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InventoryLogsRef = AutoDisposeFutureProviderRef<List<InventoryLog>>;
String _$suppliersControllerHash() =>
    r'94f85d9fffd55ab9bcaf1612207b5d34a02108bb';

/// See also [SuppliersController].
@ProviderFor(SuppliersController)
final suppliersControllerProvider = AutoDisposeAsyncNotifierProvider<
    SuppliersController, List<Supplier>>.internal(
  SuppliersController.new,
  name: r'suppliersControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$suppliersControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SuppliersController = AutoDisposeAsyncNotifier<List<Supplier>>;
String _$ingredientsControllerHash() =>
    r'ef8bd8cce5ebfa3e78ee8951d33c690957128d4f';

/// See also [IngredientsController].
@ProviderFor(IngredientsController)
final ingredientsControllerProvider = AutoDisposeAsyncNotifierProvider<
    IngredientsController, List<Ingredient>>.internal(
  IngredientsController.new,
  name: r'ingredientsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ingredientsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$IngredientsController = AutoDisposeAsyncNotifier<List<Ingredient>>;
String _$purchaseOrdersControllerHash() =>
    r'94d318658fa7f0f356748818056186f8a0d970b7';

/// See also [PurchaseOrdersController].
@ProviderFor(PurchaseOrdersController)
final purchaseOrdersControllerProvider = AutoDisposeAsyncNotifierProvider<
    PurchaseOrdersController, List<PurchaseOrder>>.internal(
  PurchaseOrdersController.new,
  name: r'purchaseOrdersControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$purchaseOrdersControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PurchaseOrdersController
    = AutoDisposeAsyncNotifier<List<PurchaseOrder>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
