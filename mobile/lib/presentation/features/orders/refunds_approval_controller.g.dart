// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refunds_approval_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pendingRefundsHash() => r'501c27971955560ad0a0cc6e5028df827a782f07';

/// See also [pendingRefunds].
@ProviderFor(pendingRefunds)
final pendingRefundsProvider = AutoDisposeFutureProvider<List<Refund>>.internal(
  pendingRefunds,
  name: r'pendingRefundsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingRefundsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingRefundsRef = AutoDisposeFutureProviderRef<List<Refund>>;
String _$refundsActionsControllerHash() =>
    r'564b7f4a31b63af26a5709d54864b1bfe3307772';

/// See also [RefundsActionsController].
@ProviderFor(RefundsActionsController)
final refundsActionsControllerProvider =
    AutoDisposeAsyncNotifierProvider<RefundsActionsController, void>.internal(
  RefundsActionsController.new,
  name: r'refundsActionsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$refundsActionsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RefundsActionsController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
