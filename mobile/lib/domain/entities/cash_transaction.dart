import 'package:equatable/equatable.dart';

class CashTransaction extends Equatable {
  final String id;
  final String shiftId;
  final String type; // IN, OUT
  final double amount;
  final String reason;
  final DateTime createdAt;

  const CashTransaction({
    required this.id,
    required this.shiftId,
    required this.type,
    required this.amount,
    required this.reason,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, shiftId, type, amount, reason, createdAt];
}
