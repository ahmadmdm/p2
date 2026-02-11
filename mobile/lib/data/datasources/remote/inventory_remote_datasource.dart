import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/network_service.dart';

part 'inventory_remote_datasource.g.dart';

@riverpod
InventoryRemoteDataSource inventoryRemoteDataSource(
    InventoryRemoteDataSourceRef ref) {
  return InventoryRemoteDataSource(ref.watch(networkServiceProvider));
}

class InventoryRemoteDataSource {
  final Dio _dio;

  InventoryRemoteDataSource(this._dio);

  // --- Suppliers ---
  Future<List<dynamic>> getSuppliers(String token) async {
    final response = await _dio.get(
      '/suppliers',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<dynamic> createSupplier(
      String token, Map<String, dynamic> data) async {
    final response = await _dio.post(
      '/suppliers',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  // --- Ingredients ---
  Future<List<dynamic>> getIngredients(String token) async {
    final response = await _dio.get(
      '/inventory/ingredients',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<dynamic> createIngredient(
      String token, Map<String, dynamic> data) async {
    final response = await _dio.post(
      '/inventory/ingredients',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<dynamic> updateStock(String token, String ingredientId, double change,
      {String? warehouseId, String? reason, String? notes}) async {
    final response = await _dio.post(
      '/inventory/stock/$ingredientId',
      data: {
        'change': change,
        'warehouseId': warehouseId,
        'reason': reason,
        'notes': notes,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<List<dynamic>> getInventoryLogs(String token) async {
    final response = await _dio.get(
      '/inventory/logs',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  // --- Warehouses ---
  Future<List<dynamic>> getWarehouses(String token) async {
    final response = await _dio.get(
      '/inventory/warehouses',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  // --- Recipes ---
  Future<List<dynamic>> getProductRecipe(String token, String productId) async {
    final response = await _dio.get(
      '/inventory/recipes/$productId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<List<dynamic>> getModifierRecipe(
      String token, String modifierId) async {
    final response = await _dio.get(
      '/inventory/recipes/modifier/$modifierId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<List<dynamic>> getAllRecipes(String token) async {
    final response = await _dio.get(
      '/inventory/recipes/all',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<dynamic> addRecipeItem(String token, Map<String, dynamic> data) async {
    final response = await _dio.post(
      '/inventory/recipes',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<dynamic> addModifierRecipeItem(
      String token, Map<String, dynamic> data) async {
    final response = await _dio.post(
      '/inventory/recipes/modifier',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  // --- Purchase Orders ---
  Future<List<dynamic>> getPurchaseOrders(String token) async {
    final response = await _dio.get(
      '/purchasing/orders',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<dynamic> createPurchaseOrder(
      String token, Map<String, dynamic> data) async {
    final response = await _dio.post(
      '/purchasing/orders',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<dynamic> addPOItem(
      String token, String poId, Map<String, dynamic> data) async {
    final response = await _dio.post(
      '/purchasing/orders/$poId/items',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<dynamic> updatePOStatus(
      String token, String poId, String status) async {
    final response = await _dio.put(
      '/purchasing/orders/$poId/status',
      data: {'status': status},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }
}
