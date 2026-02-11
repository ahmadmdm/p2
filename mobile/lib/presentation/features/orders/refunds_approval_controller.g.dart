// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refunds_approval_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pendingRefundsHash() => r'34deba132935ba6eac91b48243706ee65e27a7c1';

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
    r'f31b6d23f0ed184eb8189558a09ecf87b6b83881';

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
