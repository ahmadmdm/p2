import 'package:freezed_annotation/freezed_annotation.dart';

part 'modifier.freezed.dart';
part 'modifier.g.dart';

@freezed
class ModifierItem with _$ModifierItem {
  const factory ModifierItem({
    required String id,
    required String nameEn,
    required String nameAr,
    required double price,
  }) = _ModifierItem;

  factory ModifierItem.fromJson(Map<String, dynamic> json) => _$ModifierItemFromJson(json);
}

@freezed
class ModifierGroup with _$ModifierGroup {
  const factory ModifierGroup({
    required String id,
    required String nameEn,
    required String nameAr,
    @Default('SINGLE') String selectionType, // SINGLE, MULTIPLE
    @Default(0) int minSelection,
    @Default(1) int maxSelection,
    @Default([]) List<ModifierItem> items,
  }) = _ModifierGroup;

  factory ModifierGroup.fromJson(Map<String, dynamic> json) => _$ModifierGroupFromJson(json);
}
