import 'package:freezed_annotation/freezed_annotation.dart';
import 'supplier.dart';
import 'ingredient.dart';

part 'purchase_order.freezed.dart';
part 'purchase_order.g.dart';

@freezed
class PurchaseOrderItem with _$PurchaseOrderItem {
  const factory PurchaseOrderItem({
    required String id,
    required String ingredientId,
    Ingredient? ingredient,
    required double quantity,
    required double unitPrice,
    required double totalPrice,
  }) = _PurchaseOrderItem;

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) => _$PurchaseOrderItemFromJson(json);
}

@freezed
class PurchaseOrder with _$PurchaseOrder {
  const factory PurchaseOrder({
    required String id,
    required String supplierId,
    Supplier? supplier,
    required String status, // draft, ordered, received, cancelled
    @Default(0.0) double totalAmount,
    String? expectedDeliveryDate,
    String? paymentDueDate,
    String? notes,
    @Default([]) List<PurchaseOrderItem> items,
    required String createdAt,
  }) = _PurchaseOrder;

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) => _$PurchaseOrderFromJson(json);
}
