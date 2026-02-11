// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoriesStreamHash() => r'ff78da270faac8120184bd6ba195e33491ace71d';

/// See also [categoriesStream].
@ProviderFor(categoriesStream)
final categoriesStreamProvider =
    AutoDisposeStreamProvider<List<Category>>.internal(
  categoriesStream,
  name: r'categoriesStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoriesStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoriesStreamRef = AutoDisposeStreamProviderRef<List<Category>>;
String _$productsStreamHash() => r'318bd4ee1e4452ad5a8daa88f4fb007f8beee72e';

/// See also [productsStream].
@ProviderFor(productsStream)
final productsStreamProvider =
    AutoDisposeStreamProvider<List<Product>>.internal(
  productsStream,
  name: r'productsStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductsStreamRef = AutoDisposeStreamProviderRef<List<Product>>;
String _$filteredProductsStreamHash() =>
    r'd1448d5c1dea28c0b8f4f7ff0b18d7679c053b4a';

/// See also [filteredProductsStream].
@ProviderFor(filteredProductsStream)
final filteredProductsStreamProvider =
    AutoDisposeStreamProvider<List<Product>>.internal(
  filteredProductsStream,
  name: r'filteredProductsStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredProductsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredProductsStreamRef = AutoDisposeStreamProviderRef<List<Product>>;
String _$selectedCategoryIdHash() =>
    r'e200877d189e9efa39b0a04655f56101e28aaf21';

/// See also [SelectedCategoryId].
@ProviderFor(SelectedCategoryId)
final selectedCategoryIdProvider =
    AutoDisposeNotifierProvider<SelectedCategoryId, String?>.internal(
  SelectedCategoryId.new,
  name: r'selectedCategoryIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedCategoryIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedCategoryId = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
