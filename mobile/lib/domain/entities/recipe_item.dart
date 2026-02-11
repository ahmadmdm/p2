import 'package:freezed_annotation/freezed_annotation.dart';
import 'ingredient.dart';

part 'recipe_item.freezed.dart';
part 'recipe_item.g.dart';

@freezed
class RecipeItem with _$RecipeItem {
  const factory RecipeItem({
    required String id,
    String? productId,
    String? modifierItemId,
    required Ingredient ingredient,
    required double quantity,
  }) = _RecipeItem;

  factory RecipeItem.fromJson(Map<String, dynamic> json) => _$RecipeItemFromJson(json);
}
