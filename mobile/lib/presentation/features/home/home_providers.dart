import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/product.dart';
import '../../../data/repositories/catalog_repository_impl.dart';

part 'home_providers.g.dart';

@riverpod
class SelectedCategoryId extends _$SelectedCategoryId {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

@riverpod
Stream<List<Category>> categoriesStream(CategoriesStreamRef ref) {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.watchCategories();
}

@riverpod
Stream<List<Product>> productsStream(ProductsStreamRef ref) {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.watchProducts();
}

@riverpod
Stream<List<Product>> filteredProductsStream(FilteredProductsStreamRef ref) {
  final selectedId = ref.watch(selectedCategoryIdProvider);
  return ref.watch(productsStreamProvider.stream).map((products) {
    if (selectedId == null) return products;
    return products.where((p) => p.categoryId == selectedId).toList();
  });
}
