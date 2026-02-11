import 'package:equatable/equatable.dart';
import 'warehouse.dart';

class InventoryItem extends Equatable {
  final String id;
  final Warehouse? warehouse;
  final double quantity;
  final double minLevel;

  const InventoryItem({
    required this.id,
    this.warehouse,
    this.quantity = 0,
    this.minLevel = 0,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      warehouse: json['warehouse'] != null ? Warehouse.fromJson(json['warehouse']) : null,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      minLevel: (json['minLevel'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warehouse': warehouse?.toJson(),
      'quantity': quantity,
      'minLevel': minLevel,
    };
  }

  @override
  List<Object?> get props => [id, warehouse, quantity, minLevel];
}
