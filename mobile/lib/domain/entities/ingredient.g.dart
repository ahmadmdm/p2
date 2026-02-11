// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IngredientImpl _$$IngredientImplFromJson(Map<String, dynamic> json) =>
    _$IngredientImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      currentStock: (json['currentStock'] as num?)?.toDouble() ?? 0.0,
      minLevel: (json['minLevel'] as num?)?.toDouble() ?? 0.0,
      costPerUnit: (json['costPerUnit'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as List<dynamic>?)
              ?.map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$IngredientImplToJson(_$IngredientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'unit': instance.unit,
      'currentStock': instance.currentStock,
      'minLevel': instance.minLevel,
      'costPerUnit': instance.costPerUnit,
      'stock': instance.stock,
    };
