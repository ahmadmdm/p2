import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/recipe_item.dart';
import '../../../data/repositories/inventory_repository_impl.dart';

part 'recipes_controller.g.dart';

@riverpod
class ProductRecipesController extends _$ProductRecipesController {
  @override
  FutureOr<List<RecipeItem>> build(String productId) {
    return ref.read(inventoryRepositoryProvider).getProductRecipe(productId);
  }

  Future<void> addRecipeItem(String ingredientId, double quantity) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(inventoryRepositoryProvider)
          .addRecipeItem(productId, ingredientId, quantity);
      return ref.read(inventoryRepositoryProvider).getProductRecipe(productId);
    });
  }
}

@riverpod
class ModifierRecipesController extends _$ModifierRecipesController {
  @override
  FutureOr<List<RecipeItem>> build(String modifierId) {
    return ref.read(inventoryRepositoryProvider).getModifierRecipe(modifierId);
  }

  Future<void> addRecipeItem(String ingredientId, double quantity) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(inventoryRepositoryProvider)
          .addModifierRecipeItem(modifierId, ingredientId, quantity);
      return ref
          .read(inventoryRepositoryProvider)
          .getModifierRecipe(modifierId);
    });
  }
}
