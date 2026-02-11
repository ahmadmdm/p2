import '../entities/category.dart';
import '../entities/product.dart';

abstract class CatalogRepository {
  Stream<List<Category>> watchCategories();
  Stream<List<Product>> watchProducts();
  Future<void> syncCatalog(String token);
}
