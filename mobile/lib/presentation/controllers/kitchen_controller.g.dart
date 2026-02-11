// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stationsHash() => r'9f4c00b6d8081b3d2a6bf546510378dae8fa61c9';

/// See also [stations].
@ProviderFor(stations)
final stationsProvider = AutoDisposeFutureProvider<List<dynamic>>.internal(
  stations,
  name: r'stationsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$stationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StationsRef = AutoDisposeFutureProviderRef<List<dynamic>>;
String _$kitchenControllerHash() => r'23ea77099917cd96cf80d90c077afab6b292dc22';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$KitchenController
    extends BuildlessAutoDisposeAsyncNotifier<List<Order>> {
  late final String? stationId;

  FutureOr<List<Order>> build(
    String? stationId,
  );
}

/// See also [KitchenController].
@ProviderFor(KitchenController)
const kitchenControllerProvider = KitchenControllerFamily();

/// See also [KitchenController].
class KitchenControllerFamily extends Family<AsyncValue<List<Order>>> {
  /// See also [KitchenController].
  const KitchenControllerFamily();

  /// See also [KitchenController].
  KitchenControllerProvider call(
    String? stationId,
  ) {
    return KitchenControllerProvider(
      stationId,
    );
  }

  @override
  KitchenControllerProvider getProviderOverride(
    covariant KitchenControllerProvider provider,
  ) {
    return call(
      provider.stationId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'kitchenControllerProvider';
}

/// See also [KitchenController].
class KitchenControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    KitchenController, List<Order>> {
  /// See also [KitchenController].
  KitchenControllerProvider(
    String? stationId,
  ) : this._internal(
          () => KitchenController()..stationId = stationId,
          from: kitchenControllerProvider,
          name: r'kitchenControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$kitchenControllerHash,
          dependencies: KitchenControllerFamily._dependencies,
          allTransitiveDependencies:
              KitchenControllerFamily._allTransitiveDependencies,
          stationId: stationId,
        );

  KitchenControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.stationId,
  }) : super.internal();

  final String? stationId;

  @override
  FutureOr<List<Order>> runNotifierBuild(
    covariant KitchenController notifier,
  ) {
    return notifier.build(
      stationId,
    );
  }

  @override
  Override overrideWith(KitchenController Function() create) {
    return ProviderOverride(
      origin: this,
      override: KitchenControllerProvider._internal(
        () => create()..stationId = stationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        stationId: stationId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<KitchenController, List<Order>>
      createElement() {
    return _KitchenControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is KitchenControllerProvider && other.stationId == stationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, stationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin KitchenControllerRef on AutoDisposeAsyncNotifierProviderRef<List<Order>> {
  /// The parameter `stationId` of this provider.
  String? get stationId;
}

class _KitchenControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<KitchenController,
        List<Order>> with KitchenControllerRef {
  _KitchenControllerProviderElement(super.provider);

  @override
  String? get stationId => (origin as KitchenControllerProvider).stationId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
