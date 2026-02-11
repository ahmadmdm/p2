import 'package:freezed_annotation/freezed_annotation.dart';
import 'modifier.dart';
import 'station.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String categoryId,
    required String nameEn,
    required String nameAr,
    required double price,
    required bool isAvailable,
    @Default([]) List<ModifierGroup> modifierGroups,
    Station? station,
    @Default('OTHER') String course,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
