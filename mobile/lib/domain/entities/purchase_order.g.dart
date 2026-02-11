// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PurchaseOrderItemImpl _$$PurchaseOrderItemImplFromJson(
        Map<String, dynamic> json) =>
    _$PurchaseOrderItemImpl(
      id: json['id'] as String,
      ingredientId: json['ingredientId'] as String,
      ingredient: json['ingredient'] == null
          ? null
          : Ingredient.fromJson(json['ingredient'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );

Map<String, dynamic> _$$PurchaseOrderItemImplToJson(
        _$PurchaseOrderItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ingredientId': instance.ingredientId,
      'ingredient': instance.ingredient,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
    };

_$PurchaseOrderImpl _$$PurchaseOrderImplFromJson(Map<String, dynamic> json) =>
    _$PurchaseOrderImpl(
      id: json['id'] as String,
      supplierId: json['supplierId'] as String,
      supplier: json['supplier'] == null
          ? null
          : Supplier.fromJson(json['supplier'] as Map<String, dynamic>),
      status: json['status'] as String,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      expectedDeliveryDate: json['expectedDeliveryDate'] as String?,
      paymentDueDate: json['paymentDueDate'] as String?,
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map(
                  (e) => PurchaseOrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$$PurchaseOrderImplToJson(_$PurchaseOrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'supplierId': instance.supplierId,
      'supplier': instance.supplier,
      'status': instance.status,
      'totalAmount': instance.totalAmount,
      'expectedDeliveryDate': instance.expectedDeliveryDate,
      'paymentDueDate': instance.paymentDueDate,
      'notes': instance.notes,
      'items': instance.items,
      'createdAt': instance.createdAt,
    };
