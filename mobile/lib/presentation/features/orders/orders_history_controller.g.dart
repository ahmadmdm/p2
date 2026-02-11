// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ordersHistoryHash() => r'cf9d621b15dea2cc536900f9d69d75bcf83d734d';

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
    r'e5ac84ec460653350ab068c77d1eb7d5fbc8f5c9';

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
