// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipes_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productRecipesControllerHash() =>
    r'9ad86e6d02a2a4b003c0f9cfc6eadb5ff9135ff8';

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

abstract class _$ProductRecipesController
    extends BuildlessAutoDisposeAsyncNotifier<List<RecipeItem>> {
  late final String productId;

  FutureOr<List<RecipeItem>> build(
    String productId,
  );
}

/// See also [ProductRecipesController].
@ProviderFor(ProductRecipesController)
const productRecipesControllerProvider = ProductRecipesControllerFamily();

/// See also [ProductRecipesController].
class ProductRecipesControllerFamily
    extends Family<AsyncValue<List<RecipeItem>>> {
  /// See also [ProductRecipesController].
  const ProductRecipesControllerFamily();

  /// See also [ProductRecipesController].
  ProductRecipesControllerProvider call(
    String productId,
  ) {
    return ProductRecipesControllerProvider(
      productId,
    );
  }

  @override
  ProductRecipesControllerProvider getProviderOverride(
    covariant ProductRecipesControllerProvider provider,
  ) {
    return call(
      provider.productId,
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
  String? get name => r'productRecipesControllerProvider';
}

/// See also [ProductRecipesController].
class ProductRecipesControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ProductRecipesController,
        List<RecipeItem>> {
  /// See also [ProductRecipesController].
  ProductRecipesControllerProvider(
    String productId,
  ) : this._internal(
          () => ProductRecipesController()..productId = productId,
          from: productRecipesControllerProvider,
          name: r'productRecipesControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productRecipesControllerHash,
          dependencies: ProductRecipesControllerFamily._dependencies,
          allTransitiveDependencies:
              ProductRecipesControllerFamily._allTransitiveDependencies,
          productId: productId,
        );

  ProductRecipesControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  FutureOr<List<RecipeItem>> runNotifierBuild(
    covariant ProductRecipesController notifier,
  ) {
    return notifier.build(
      productId,
    );
  }

  @override
  Override overrideWith(ProductRecipesController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProductRecipesControllerProvider._internal(
        () => create()..productId = productId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ProductRecipesController,
      List<RecipeItem>> createElement() {
    return _ProductRecipesControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductRecipesControllerProvider &&
        other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductRecipesControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<RecipeItem>> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _ProductRecipesControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ProductRecipesController,
        List<RecipeItem>> with ProductRecipesControllerRef {
  _ProductRecipesControllerProviderElement(super.provider);

  @override
  String get productId =>
      (origin as ProductRecipesControllerProvider).productId;
}

String _$modifierRecipesControllerHash() =>
    r'db1483ae6873590730521998f14b10d73693f827';

abstract class _$ModifierRecipesController
    extends BuildlessAutoDisposeAsyncNotifier<List<RecipeItem>> {
  late final String modifierId;

  FutureOr<List<RecipeItem>> build(
    String modifierId,
  );
}

/// See also [ModifierRecipesController].
@ProviderFor(ModifierRecipesController)
const modifierRecipesControllerProvider = ModifierRecipesControllerFamily();

/// See also [ModifierRecipesController].
class ModifierRecipesControllerFamily
    extends Family<AsyncValue<List<RecipeItem>>> {
  /// See also [ModifierRecipesController].
  const ModifierRecipesControllerFamily();

  /// See also [ModifierRecipesController].
  ModifierRecipesControllerProvider call(
    String modifierId,
  ) {
    return ModifierRecipesControllerProvider(
      modifierId,
    );
  }

  @override
  ModifierRecipesControllerProvider getProviderOverride(
    covariant ModifierRecipesControllerProvider provider,
  ) {
    return call(
      provider.modifierId,
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
  String? get name => r'modifierRecipesControllerProvider';
}

/// See also [ModifierRecipesController].
class ModifierRecipesControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ModifierRecipesController,
        List<RecipeItem>> {
  /// See also [ModifierRecipesController].
  ModifierRecipesControllerProvider(
    String modifierId,
  ) : this._internal(
          () => ModifierRecipesController()..modifierId = modifierId,
          from: modifierRecipesControllerProvider,
          name: r'modifierRecipesControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$modifierRecipesControllerHash,
          dependencies: ModifierRecipesControllerFamily._dependencies,
          allTransitiveDependencies:
              ModifierRecipesControllerFamily._allTransitiveDependencies,
          modifierId: modifierId,
        );

  ModifierRecipesControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.modifierId,
  }) : super.internal();

  final String modifierId;

  @override
  FutureOr<List<RecipeItem>> runNotifierBuild(
    covariant ModifierRecipesController notifier,
  ) {
    return notifier.build(
      modifierId,
    );
  }

  @override
  Override overrideWith(ModifierRecipesController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ModifierRecipesControllerProvider._internal(
        () => create()..modifierId = modifierId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        modifierId: modifierId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ModifierRecipesController,
      List<RecipeItem>> createElement() {
    return _ModifierRecipesControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ModifierRecipesControllerProvider &&
        other.modifierId == modifierId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, modifierId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ModifierRecipesControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<RecipeItem>> {
  /// The parameter `modifierId` of this provider.
  String get modifierId;
}

class _ModifierRecipesControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ModifierRecipesController,
        List<RecipeItem>> with ModifierRecipesControllerRef {
  _ModifierRecipesControllerProviderElement(super.provider);

  @override
  String get modifierId =>
      (origin as ModifierRecipesControllerProvider).modifierId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
