// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      nameEn: json['nameEn'] as String,
      nameAr: json['nameAr'] as String,
      price: (json['price'] as num).toDouble(),
      isAvailable: json['isAvailable'] as bool,
      modifierGroups: (json['modifierGroups'] as List<dynamic>?)
              ?.map((e) => ModifierGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      station: json['station'] == null
          ? null
          : Station.fromJson(json['station'] as Map<String, dynamic>),
      course: json['course'] as String? ?? 'OTHER',
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'nameEn': instance.nameEn,
      'nameAr': instance.nameAr,
      'price': instance.price,
      'isAvailable': instance.isAvailable,
      'modifierGroups': instance.modifierGroups,
      'station': instance.station,
      'course': instance.course,
    };
