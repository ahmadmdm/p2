import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant_table.freezed.dart';
part 'restaurant_table.g.dart';

@freezed
class RestaurantTable with _$RestaurantTable {
  const factory RestaurantTable({
    required String id,
    required String tableNumber,
    String? section,
    @Default(4) int capacity,
    @Default(0.0) double x,
    @Default(0.0) double y,
    @Default(100.0) double width,
    @Default(100.0) double height,
    @Default('rectangle') String shape,
    @Default(0.0) double rotation,
    @Default('free') String status,
    String? qrCode,
  }) = _RestaurantTable;

  factory RestaurantTable.fromJson(Map<String, dynamic> json) => _$RestaurantTableFromJson(json);
}
