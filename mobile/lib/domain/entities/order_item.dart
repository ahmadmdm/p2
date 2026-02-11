import 'package:equatable/equatable.dart';
import 'product.dart';
import 'modifier.dart';

class OrderItem extends Equatable {
  final String id;
  final Product product;
  final int quantity;
  final double price;
  final double taxAmount;
  final double discountAmount;
  final String? notes;
  final List<ModifierItem> modifiers;
  final String? status; // PENDING, PREPARING, READY, SERVED

  const OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    this.notes,
    this.modifiers = const [],
    this.status = 'PENDING',
  });

  @override
  List<Object?> get props => [
        id,
        product,
        quantity,
        price,
        taxAmount,
        discountAmount,
        notes,
        modifiers,
        status
      ];

  OrderItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    double? price,
    double? taxAmount,
    double? discountAmount,
    String? notes,
    List<ModifierItem>? modifiers,
    String? status,
  }) {
    return OrderItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      notes: notes ?? this.notes,
      modifiers: modifiers ?? this.modifiers,
      status: status ?? this.status,
    );
  }
}
