import '../entities/shift.dart';
import '../entities/cash_transaction.dart';

abstract class ShiftsRepository {
  Future<Shift?> getOpenShift(String userId);
  Future<void> openShift(String userId, double startingCash, String? deviceId);
  Future<void> closeShift(String shiftId, double endingCash, String? notes);
  Future<void> addCashTransaction(
      String shiftId, String type, double amount, String reason);
  Future<List<CashTransaction>> getCashTransactions(String shiftId);
  Future<void> syncShifts(String token); // Sync with backend
}
