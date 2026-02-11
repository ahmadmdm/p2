import 'package:freezed_annotation/freezed_annotation.dart';
import 'inventory_item.dart';

part 'ingredient.freezed.dart';
part 'ingredient.g.dart';

@freezed
class Ingredient with _$Ingredient {
  const factory Ingredient({
    required String id,
    required String name,
    required String unit,
    @Default(0.0) double currentStock,
    @Default(0.0) double minLevel,
    @Default(0.0) double costPerUnit,
    @Default([]) List<InventoryItem> stock,
  }) = _Ingredient;

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);
}
