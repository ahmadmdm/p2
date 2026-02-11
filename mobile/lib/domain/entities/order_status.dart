enum OrderStatus {
  PENDING,
  PREPARING,
  READY,
  SERVED,
  COMPLETED,
  CANCELLED,
  VOIDED,
  REFUNDED,
  HELD,
  ON_DELIVERY,
  DELIVERED,
}

OrderStatus parseOrderStatus(String status) {
  switch (status) {
    case 'PENDING':
      return OrderStatus.PENDING;
    case 'PREPARING':
      return OrderStatus.PREPARING;
    case 'READY':
      return OrderStatus.READY;
    case 'SERVED':
      return OrderStatus.SERVED;
    case 'COMPLETED':
      return OrderStatus.COMPLETED;
    case 'CANCELLED':
      return OrderStatus.CANCELLED;
    case 'VOIDED':
      return OrderStatus.VOIDED;
    case 'REFUNDED':
      return OrderStatus.REFUNDED;
    case 'HELD':
      return OrderStatus.HELD;
    case 'ON_DELIVERY':
      return OrderStatus.ON_DELIVERY;
    case 'DELIVERED':
      return OrderStatus.DELIVERED;
    default:
      return OrderStatus.PENDING;
  }
}

extension OrderStatusExtension on OrderStatus {
  String get name {
    switch (this) {
      case OrderStatus.PENDING:
        return 'PENDING';
      case OrderStatus.PREPARING:
        return 'PREPARING';
      case OrderStatus.READY:
        return 'READY';
      case OrderStatus.SERVED:
        return 'SERVED';
      case OrderStatus.COMPLETED:
        return 'COMPLETED';
      case OrderStatus.CANCELLED:
        return 'CANCELLED';
      case OrderStatus.VOIDED:
        return 'VOIDED';
      case OrderStatus.REFUNDED:
        return 'REFUNDED';
      case OrderStatus.HELD:
        return 'HELD';
      case OrderStatus.ON_DELIVERY:
        return 'ON_DELIVERY';
      case OrderStatus.DELIVERED:
        return 'DELIVERED';
    }
  }
}
