// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modifier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ModifierItemImpl _$$ModifierItemImplFromJson(Map<String, dynamic> json) =>
    _$ModifierItemImpl(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      nameAr: json['nameAr'] as String,
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$$ModifierItemImplToJson(_$ModifierItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameEn': instance.nameEn,
      'nameAr': instance.nameAr,
      'price': instance.price,
    };

_$ModifierGroupImpl _$$ModifierGroupImplFromJson(Map<String, dynamic> json) =>
    _$ModifierGroupImpl(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      nameAr: json['nameAr'] as String,
      selectionType: json['selectionType'] as String? ?? 'SINGLE',
      minSelection: (json['minSelection'] as num?)?.toInt() ?? 0,
      maxSelection: (json['maxSelection'] as num?)?.toInt() ?? 1,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ModifierItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ModifierGroupImplToJson(_$ModifierGroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameEn': instance.nameEn,
      'nameAr': instance.nameAr,
      'selectionType': instance.selectionType,
      'minSelection': instance.minSelection,
      'maxSelection': instance.maxSelection,
      'items': instance.items,
    };
