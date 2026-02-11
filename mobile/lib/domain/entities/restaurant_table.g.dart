// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RestaurantTableImpl _$$RestaurantTableImplFromJson(
        Map<String, dynamic> json) =>
    _$RestaurantTableImpl(
      id: json['id'] as String,
      tableNumber: json['tableNumber'] as String,
      section: json['section'] as String?,
      capacity: (json['capacity'] as num?)?.toInt() ?? 4,
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 100.0,
      height: (json['height'] as num?)?.toDouble() ?? 100.0,
      shape: json['shape'] as String? ?? 'rectangle',
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'free',
      qrCode: json['qrCode'] as String?,
    );

Map<String, dynamic> _$$RestaurantTableImplToJson(
        _$RestaurantTableImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tableNumber': instance.tableNumber,
      'section': instance.section,
      'capacity': instance.capacity,
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'shape': instance.shape,
      'rotation': instance.rotation,
      'status': instance.status,
      'qrCode': instance.qrCode,
    };
