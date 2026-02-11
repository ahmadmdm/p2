// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ordersHistoryHash() => r'9008630be1156bc3519f51b51b320b89be519d59';

/// See also [ordersHistory].
@ProviderFor(ordersHistory)
final ordersHistoryProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  ordersHistory,
  name: r'ordersHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ordersHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrdersHistoryRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$ordersActionsControllerHash() =>
    r'f293ab03210c335f83783251e7355fc3c7db1aee';

/// See also [OrdersActionsController].
@ProviderFor(OrdersActionsController)
final ordersActionsControllerProvider =
    AutoDisposeAsyncNotifierProvider<OrdersActionsController, void>.internal(
  OrdersActionsController.new,
  name: r'ordersActionsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ordersActionsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OrdersActionsController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
