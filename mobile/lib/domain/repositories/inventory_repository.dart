import '../entities/recipe_item.dart';
import '../entities/supplier.dart';
import '../entities/ingredient.dart';
import '../entities/purchase_order.dart';
import '../entities/warehouse.dart';
import '../entities/inventory_log.dart';

abstract class InventoryRepository {
  // Warehouses
  Future<List<Warehouse>> getWarehouses();

  // Suppliers
  Future<List<Supplier>> getSuppliers();
  Future<Supplier> createSupplier(String name, String? email, String? phone);

  // Ingredients
  Future<List<Ingredient>> getIngredients();
  Future<Ingredient> createIngredient(String name, String unit);
  Future<void> updateStock(String ingredientId, double change,
      {String? warehouseId, String? reason, String? notes});
  Future<List<InventoryLog>> getInventoryLogs();

  // POs
  Future<List<PurchaseOrder>> getPurchaseOrders();
  Future<PurchaseOrder> createPurchaseOrder(String supplierId, String? notes);
  Future<PurchaseOrder> addPOItem(
      String poId, String ingredientId, double quantity, double unitPrice);
  Future<PurchaseOrder> receivePO(String poId);

  // Recipes
  Future<List<RecipeItem>> getProductRecipe(String productId);
  Future<List<RecipeItem>> getModifierRecipe(String modifierId);
  Future<RecipeItem> addRecipeItem(
      String productId, String ingredientId, double quantity);
  Future<RecipeItem> addModifierRecipeItem(
      String modifierId, String ingredientId, double quantity);

  Future<void> syncInventory(String token);
  Future<void> syncPendingPurchaseOrders(String token);
}
