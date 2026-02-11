import 'package:equatable/equatable.dart';

class Shift extends Equatable {
  final String id;
  final String userId;
  final String? deviceId;
  final DateTime startTime;
  final DateTime? endTime;
  final double startingCash;
  final double? endingCash;
  final double? expectedCash;
  final double? difference;
  final String status; // OPEN, CLOSED
  final String? notes;

  const Shift({
    required this.id,
    required this.userId,
    this.deviceId,
    required this.startTime,
    this.endTime,
    required this.startingCash,
    this.endingCash,
    this.expectedCash,
    this.difference,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        deviceId,
        startTime,
        endTime,
        startingCash,
        endingCash,
        expectedCash,
        difference,
        status,
        notes,
      ];
}
