import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_provider.g.dart';

class CartItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final List<dynamic> modifiers;
  final String? notes;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.modifiers = const [],
    this.notes,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
      modifiers: modifiers,
      notes: notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          notes == other.notes &&
          _areModifiersEqual(modifiers, other.modifiers);

  @override
  int get hashCode =>
      productId.hashCode ^ _modifiersHashCode(modifiers) ^ notes.hashCode;

  bool _areModifiersEqual(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    // Assuming simple list of objects or strings.
    // Ideally modifiers should be sorted or structured to ensure order doesn't matter.
    // For now, let's assume strict order or just implement simple string check if they are IDs.
    // If modifiers are complex objects, we need deep comparison.
    // Let's assume modifiers are List<Map<String, dynamic>>.
    // A simple JSON stringify comparison might be easiest for this context.
    final aStr = a.toString();
    final bStr = b.toString();
    return aStr == bStr;
  }

  int _modifiersHashCode(List<dynamic> mods) {
    return mods.toString().hashCode;
  }
}

@riverpod
class Cart extends _$Cart {
  @override
  List<CartItem> build() => [];

  void addItem(CartItem item) {
    // Check if item already exists with same modifiers
    final index = state.indexWhere(
      (i) =>
          i.productId == item.productId &&
          i._areModifiersEqual(i.modifiers, item.modifiers),
    );

    if (index >= 0) {
      final existing = state[index];
      state = [
        ...state.sublist(0, index),
        existing.copyWith(quantity: existing.quantity + item.quantity),
        ...state.sublist(index + 1),
      ];
    } else {
      state = [...state, item];
    }
  }

  void updateQuantity(CartItem item, int delta) {
    final index = state.indexOf(item);
    if (index >= 0) {
      final existing = state[index];
      final newQuantity = existing.quantity + delta;
      if (newQuantity <= 0) {
        removeItem(item);
      } else {
        state = [
          ...state.sublist(0, index),
          existing.copyWith(quantity: newQuantity),
          ...state.sublist(index + 1),
        ];
      }
    }
  }

  void removeItem(CartItem item) {
    state = state.where((i) => i != item).toList();
  }

  void clear() {
    state = [];
  }

  double get total =>
      state.fold(0, (sum, item) => sum + (item.price * item.quantity));
}
