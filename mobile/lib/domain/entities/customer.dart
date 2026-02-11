import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final int loyaltyPoints;
  final String tier;

  const Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.loyaltyPoints = 0,
    this.tier = 'BRONZE',
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      tier: json['tier'] ?? 'BRONZE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'loyaltyPoints': loyaltyPoints,
      'tier': tier,
    };
  }

  @override
  List<Object?> get props => [id, name, phoneNumber, loyaltyPoints, tier];
}
