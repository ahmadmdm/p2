// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeItemImpl _$$RecipeItemImplFromJson(Map<String, dynamic> json) =>
    _$RecipeItemImpl(
      id: json['id'] as String,
      productId: json['productId'] as String?,
      modifierItemId: json['modifierItemId'] as String?,
      ingredient:
          Ingredient.fromJson(json['ingredient'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toDouble(),
    );

Map<String, dynamic> _$$RecipeItemImplToJson(_$RecipeItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'modifierItemId': instance.modifierItemId,
      'ingredient': instance.ingredient,
      'quantity': instance.quantity,
    };
