import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/entities/category.dart' as domain;
import '../../domain/entities/product.dart' as domain;
import '../../domain/entities/modifier.dart';
import '../../domain/entities/station.dart';
import '../datasources/remote/catalog_remote_datasource.dart';
import '../datasources/local/database.dart';

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

  double _toDouble(dynamic value, {double fallback = 0}) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  Map<String, String> _extractName(dynamic rawName) {
    if (rawName is Map) {
      final nameMap = Map<String, dynamic>.from(rawName);
      return {
        'en': nameMap['en']?.toString() ?? '',
        'ar': nameMap['ar']?.toString() ?? '',
      };
    }
    if (rawName is String) {
      return {'en': rawName, 'ar': rawName};
    }
    return {'en': '', 'ar': ''};
  }

  ModifierItem? _parseModifierItem(dynamic raw) {
    if (raw is! Map) {
      return null;
    }
    final json = Map<String, dynamic>.from(raw);
    final name = _extractName(json['name']);

    return ModifierItem(
      id: json['id']?.toString() ?? '',
      nameEn: (json['nameEn'] as String?)?.trim().isNotEmpty == true
          ? json['nameEn'] as String
          : name['en'] ?? '',
      nameAr: (json['nameAr'] as String?)?.trim().isNotEmpty == true
          ? json['nameAr'] as String
          : name['ar'] ?? '',
      price: _toDouble(json['price']),
    );
  }

  ModifierGroup? _parseModifierGroup(dynamic raw) {
    if (raw is! Map) {
      return null;
    }
    final json = Map<String, dynamic>.from(raw);
    final name = _extractName(json['name']);
    final rawItems = json['items'];
    final parsedItems = rawItems is List
        ? rawItems
            .map(_parseModifierItem)
            .whereType<ModifierItem>()
            .toList(growable: false)
        : const <ModifierItem>[];

    return ModifierGroup(
      id: json['id']?.toString() ?? '',
      nameEn: (json['nameEn'] as String?)?.trim().isNotEmpty == true
          ? json['nameEn'] as String
          : name['en'] ?? '',
      nameAr: (json['nameAr'] as String?)?.trim().isNotEmpty == true
          ? json['nameAr'] as String
          : name['ar'] ?? '',
      selectionType: json['selectionType']?.toString() ?? 'SINGLE',
      minSelection: _toInt(json['minSelection']),
      maxSelection: _toInt(json['maxSelection'], fallback: 1),
      items: parsedItems,
    );
  }

  List<ModifierGroup> _decodeModifierGroups(String? rawJson) {
    if (rawJson == null || rawJson.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .map(_parseModifierGroup)
        .whereType<ModifierGroup>()
        .toList(growable: false);
  }

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
                modifierGroups: _decodeModifierGroups(row.modifierGroups),
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
        final productName = _extractName(prod['name']);
        final categoryRaw = prod['category'];
        final categoryId = categoryRaw is Map
            ? categoryRaw['id']?.toString() ?? ''
            : categoryRaw?.toString() ?? '';
        final parsedModifierGroups = (prod['modifierGroups'] is List
                ? (prod['modifierGroups'] as List)
                    .map(_parseModifierGroup)
                    .whereType<ModifierGroup>()
                    .toList(growable: false)
                : const <ModifierGroup>[])
            .map((group) => group.toJson())
            .toList(growable: false);

        await _db.into(_db.products).insertOnConflictUpdate(
              ProductsCompanion(
                id: Value(prod['id']),
                categoryId: Value(categoryId),
                nameEn: Value(productName['en'] ?? ''),
                nameAr: Value(productName['ar'] ?? ''),
                price: Value(_toDouble(prod['price'])),
                isAvailable: Value(prod['isAvailable'] ?? true),
                modifierGroups: Value(parsedModifierGroups.isNotEmpty
                    ? jsonEncode(parsedModifierGroups)
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
