// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StationImpl _$$StationImplFromJson(Map<String, dynamic> json) =>
    _$StationImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      printerName: json['printerName'] as String?,
      printerIp: json['printerIp'] as String?,
      printerPort: (json['printerPort'] as num?)?.toInt() ?? 9100,
    );

Map<String, dynamic> _$$StationImplToJson(_$StationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'printerName': instance.printerName,
      'printerIp': instance.printerIp,
      'printerPort': instance.printerPort,
    };
