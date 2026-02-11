import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/entities/category.dart' as domain;
import '../../domain/entities/product.dart' as domain;
import '../../domain/entities/modifier.dart';
import '../../domain/entities/station.dart';
import '../datasources/remote/catalog_remote_datasource.dart';
import '../local/database.dart';

part 'catalog_repository_impl.g.dart';

@riverpod
CatalogRepository catalogRepository(CatalogRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final remoteDataSource = ref.watch(catalogRemoteDataSourceProvider);
  return CatalogRepositoryImpl(db, remoteDataSource);
}

class CatalogRepositoryImpl implements CatalogRepository {
  final AppDatabase _db;
  final CatalogRemoteDataSource _remoteDataSource;

  CatalogRepositoryImpl(this._db, this._remoteDataSource);

  @override
  Stream<List<domain.Category>> watchCategories() {
    return _db.select(_db.categories).watch().map((rows) {
      return rows
          .map((row) => domain.Category(
                id: row.id,
                nameEn: row.nameEn,
                nameAr: row.nameAr,
                sortOrder: row.sortOrder,
              ))
          .toList();
    });
  }

  @override
  Stream<List<domain.Product>> watchProducts() {
    return _db.select(_db.products).watch().map((rows) {
      return rows
          .map((row) => domain.Product(
                id: row.id,
                categoryId: row.categoryId,
                nameEn: row.nameEn,
                nameAr: row.nameAr,
                price: row.price,
                isAvailable: row.isAvailable,
                modifierGroups: row.modifierGroups != null
                    ? (jsonDecode(row.modifierGroups!) as List)
                        .map((e) => ModifierGroup.fromJson(e))
                        .toList()
                    : [],
                station: row.station != null
                    ? Station.fromJson(jsonDecode(row.station!))
                    : null,
                course: row.course,
              ))
          .toList();
    });
  }

  @override
  Future<void> syncCatalog(String token) async {
    final remoteCategories = await _remoteDataSource.getCategories(token);
    final remoteProducts = await _remoteDataSource.getProducts(token);

    await _db.transaction(() async {
      // Upsert Categories
      for (final cat in remoteCategories) {
        await _db.into(_db.categories).insertOnConflictUpdate(
              CategoriesCompanion(
                id: Value(cat['id']),
                nameEn: Value(cat['name']['en']),
                nameAr: Value(cat['name']['ar']),
                sortOrder: Value(cat['sortOrder'] ?? 0),
              ),
            );
      }

      // Upsert Products
      for (final prod in remoteProducts) {
        await _db.into(_db.products).insertOnConflictUpdate(
              ProductsCompanion(
                id: Value(prod['id']),
                categoryId: Value(prod['category']
                    ['id']), // Ensure backend sends category object or ID
                nameEn: Value(prod['name']['en']),
                nameAr: Value(prod['name']['ar']),
                price: Value(prod['price'] is String
                    ? double.parse(prod['price'])
                    : (prod['price'] as num).toDouble()),
                isAvailable: Value(prod['isAvailable'] ?? true),
                modifierGroups: Value(prod['modifierGroups'] != null
                    ? jsonEncode(prod['modifierGroups'])
                    : null),
                station: Value(prod['station'] != null
                    ? jsonEncode(prod['station'])
                    : null),
                course: Value(prod['course'] ?? 'OTHER'),
              ),
            );
      }
    });
  }
}
