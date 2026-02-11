class LoyaltyTransaction {
  final String id;
  final String customerId;
  final int points;
  final String type;
  final String? orderId;
  final String? description;
  final DateTime createdAt;

  LoyaltyTransaction({
    required this.id,
    required this.customerId,
    required this.points,
    required this.type,
    this.orderId,
    this.description,
    required this.createdAt,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction(
      id: json['id'],
      customerId: json['customerId'],
      points: json['points'],
      type: json['type'],
      orderId: json['orderId'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
