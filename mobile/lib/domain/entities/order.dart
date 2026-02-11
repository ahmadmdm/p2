import 'package:equatable/equatable.dart';
import 'order_item.dart';
import 'order_status.dart';
import 'order_type.dart';
import 'refund.dart';

class Order extends Equatable {
  final String id;
  final String? tableNumber; // For now just storing number or ID
  final OrderStatus status;
  final OrderType type;
  final String paymentMethod; // CASH, CARD, ONLINE, LATER
  final String paymentStatus; // PENDING, PAID
  final String? customerId;
  final List<OrderItem> items;
  final List<Refund>? refunds;
  final double totalAmount;
  final double taxAmount;
  final double discountAmount;
  final double deliveryFee;
  final String? deliveryAddress;
  final String? driverId;
  final String? deliveryProvider;
  final String? deliveryReferenceId;
  final DateTime createdAt;

  const Order({
    required this.id,
    this.tableNumber,
    required this.status,
    this.type = OrderType.DINE_IN,
    this.paymentMethod = 'LATER',
    this.paymentStatus = 'PENDING',
    this.customerId,
    required this.items,
    this.refunds,
    required this.totalAmount,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    this.deliveryFee = 0.0,
    this.deliveryAddress,
    this.driverId,
    this.deliveryProvider,
    this.deliveryReferenceId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        tableNumber,
        status,
        type,
        paymentMethod,
        paymentStatus,
        customerId,
        items,
        refunds,
        totalAmount,
        taxAmount,
        discountAmount,
        deliveryFee,
        deliveryAddress,
        driverId,
        deliveryProvider,
        deliveryReferenceId,
        createdAt,
      ];

  Order copyWith({
    String? id,
    String? tableNumber,
    OrderStatus? status,
    OrderType? type,
    String? paymentMethod,
    String? paymentStatus,
    String? customerId,
    List<OrderItem>? items,
    List<Refund>? refunds,
    double? totalAmount,
    double? taxAmount,
    double? discountAmount,
    double? deliveryFee,
    String? deliveryAddress,
    String? driverId,
    String? deliveryProvider,
    String? deliveryReferenceId,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      type: type ?? this.type,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      customerId: customerId ?? this.customerId,
      items: items ?? this.items,
      refunds: refunds ?? this.refunds,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      driverId: driverId ?? this.driverId,
      deliveryProvider: deliveryProvider ?? this.deliveryProvider,
      deliveryReferenceId: deliveryReferenceId ?? this.deliveryReferenceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
