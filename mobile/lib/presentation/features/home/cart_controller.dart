import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/modifier.dart';
import 'cart_state.dart';

part 'cart_controller.g.dart';

@riverpod
class CartController extends _$CartController {
  @override
  CartState build() {
    return const CartState();
  }

  void addToCart(Product product,
      {int quantity = 1,
      String? notes,
      List<ModifierItem> modifiers = const []}) {
    final items = [...state.items];

    // Check if item exists with same modifiers and notes
    final index = items.indexWhere((item) =>
            item.product.id == product.id &&
            item.notes == notes &&
            // Simple list equality check might not work for objects unless Equatable is used correctly
            // Since ModifierItem is freezed/equatable, list equality should work if order matches?
            // Actually Equatable props check list equality.
            // But let's assume always add new line if modifiers exist to avoid complexity for now,
            // or rely on Equatable.
            item.modifiers.length == modifiers.length &&
            item.modifiers.every((m) => modifiers.contains(m)) // simple check
        );

    if (index >= 0) {
      items[index] =
          items[index].copyWith(quantity: items[index].quantity + quantity);
    } else {
      items.add(CartItem(
          product: product,
          quantity: quantity,
          notes: notes,
          modifiers: modifiers));
    }

    state = state.copyWith(items: items);
  }

  void removeFromCart(Product product) {
    final items =
        state.items.where((item) => item.product.id != product.id).toList();
    state = state.copyWith(items: items);
  }

  void updateQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      removeFromCart(product);
      return;
    }

    final items = [...state.items];
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: quantity);
      state = state.copyWith(items: items);
    }
  }

  void updateNotes(Product product, String notes) {
    final items = [...state.items];
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(notes: notes);
      state = state.copyWith(items: items);
    }
  }

  void selectCustomer(Customer customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void removeCustomer() {
    state = state.copyWith(clearCustomer: true);
  }

  void setGlobalDiscount(double amount) {
    state = state.copyWith(globalDiscountAmount: amount);
  }

  void setGlobalTax(double amount) {
    state = state.copyWith(globalTaxAmount: amount);
  }

  void setItemDiscount(Product product, double amount) {
    final items = [...state.items];
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(discountAmount: amount);
      state = state.copyWith(items: items);
    }
  }

  void setItemTax(Product product, double amount) {
    final items = [...state.items];
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(taxAmount: amount);
      state = state.copyWith(items: items);
    }
  }

  void clearCart() {
    state = const CartState();
  }
}
