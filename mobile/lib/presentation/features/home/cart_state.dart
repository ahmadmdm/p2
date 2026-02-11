import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/modifier.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final String? notes;
  final List<ModifierItem> modifiers;
  final double discountAmount;
  final double taxAmount;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.notes,
    this.modifiers = const [],
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? notes,
    List<ModifierItem>? modifiers,
    double? discountAmount,
    double? taxAmount,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      modifiers: modifiers ?? this.modifiers,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
    );
  }

  double get total {
    double modifiersTotal = modifiers.fold(0, (sum, m) => sum + m.price);
    // (Price + Modifiers) * Qty - Discount + Tax
    // Note: Discount/Tax here are "per line item total", not "per unit".
    // Usually discount is per unit or total line. Let's assume total line amount for now to keep it simple.
    return ((product.price + modifiersTotal) * quantity) - discountAmount + taxAmount;
  }

  @override
  List<Object?> get props => [product, quantity, notes, modifiers, discountAmount, taxAmount];
}

class CartState extends Equatable {
  final List<CartItem> items;
  final Customer? selectedCustomer;
  final double globalDiscountAmount;
  final double globalTaxAmount;

  const CartState({
    this.items = const [],
    this.selectedCustomer,
    this.globalDiscountAmount = 0.0,
    this.globalTaxAmount = 0.0,
  });

  CartState copyWith({
    List<CartItem>? items,
    Customer? selectedCustomer,
    bool clearCustomer = false,
    double? globalDiscountAmount,
    double? globalTaxAmount,
  }) {
    return CartState(
      items: items ?? this.items,
      selectedCustomer:
          clearCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      globalDiscountAmount: globalDiscountAmount ?? this.globalDiscountAmount,
      globalTaxAmount: globalTaxAmount ?? this.globalTaxAmount,
    );
  }

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);

  double get totalAmount => subtotal - globalDiscountAmount + globalTaxAmount;
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [items, selectedCustomer, globalDiscountAmount, globalTaxAmount];
}
