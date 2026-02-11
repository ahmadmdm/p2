import 'package:equatable/equatable.dart';

class Refund extends Equatable {
  final String id;
  final double amount;
  final String reason;
  final String status;
  final String? managerId;
  final DateTime createdAt;

  const Refund({
    required this.id,
    required this.amount,
    required this.reason,
    required this.status,
    this.managerId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, amount, reason, status, managerId, createdAt];

  factory Refund.fromJson(Map<String, dynamic> json) {
    return Refund(
      id: json['id'],
      amount: json['amount'] is String ? double.parse(json['amount']) : (json['amount'] as num).toDouble(),
      reason: json['reason'],
      status: json['status'],
      managerId: json['managerId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
