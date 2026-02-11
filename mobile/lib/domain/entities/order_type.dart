enum OrderType {
  DINE_IN,
  TAKEAWAY,
  DELIVERY,
}

OrderType parseOrderType(String type) {
  switch (type) {
    case 'DINE_IN':
      return OrderType.DINE_IN;
    case 'TAKEAWAY':
      return OrderType.TAKEAWAY;
    case 'DELIVERY':
      return OrderType.DELIVERY;
    default:
      return OrderType.DINE_IN;
  }
}

extension OrderTypeExtension on OrderType {
  String get name {
    switch (this) {
      case OrderType.DINE_IN:
        return 'DINE_IN';
      case OrderType.TAKEAWAY:
        return 'TAKEAWAY';
      case OrderType.DELIVERY:
        return 'DELIVERY';
    }
  }
}
