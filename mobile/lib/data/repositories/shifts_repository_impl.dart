import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/shift.dart' as domain;
import '../../domain/entities/cash_transaction.dart' as domain;
import '../../domain/repositories/shifts_repository.dart';
import '../datasources/local/database.dart';

import '../datasources/remote/shifts_remote_datasource.dart';

part 'shifts_repository_impl.g.dart';

@Riverpod(keepAlive: true)
ShiftsRepository shiftsRepository(ShiftsRepositoryRef ref) {
  return ShiftsRepositoryImpl(
    ref.watch(appDatabaseProvider),
    ref.watch(shiftsRemoteDataSourceProvider),
  );
}

class ShiftsRepositoryImpl implements ShiftsRepository {
  final AppDatabase _db;
  final ShiftsRemoteDataSource _remoteDataSource;
  final _uuid = const Uuid();

  ShiftsRepositoryImpl(this._db, this._remoteDataSource);

  @override
  Future<domain.Shift?> getOpenShift(String userId) async {
    final query = _db.select(_db.shifts)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.status.equals('OPEN'));
    final shift = await query.getSingleOrNull();

    if (shift == null) return null;

    return domain.Shift(
      id: shift.id,
      userId: shift.userId,
      deviceId: shift.deviceId,
      startTime: shift.startTime,
      endTime: shift.endTime,
      startingCash: shift.startingCash,
      endingCash: shift.endingCash,
      expectedCash: shift.expectedCash,
      difference: shift.difference,
      status: shift.status,
      notes: shift.notes,
    );
  }

  @override
  Future<void> openShift(
      String userId, double startingCash, String? deviceId) async {
    final id = _uuid.v4();
    await _db.into(_db.shifts).insert(
          ShiftsCompanion.insert(
            id: id,
            userId: userId,
            deviceId: Value(deviceId),
            startTime: DateTime.now(),
            startingCash: startingCash,
            status: 'OPEN',
            isSynced: const Value(false),
          ),
        );
  }

  @override
  Future<void> closeShift(
      String shiftId, double endingCash, String? notes) async {
    await (_db.update(_db.shifts)..where((t) => t.id.equals(shiftId))).write(
      ShiftsCompanion(
        endTime: Value(DateTime.now()),
        endingCash: Value(endingCash),
        status: const Value('CLOSED'),
        notes: Value(notes),
        isSynced: const Value(false),
      ),
    );
  }

  @override
  Future<void> addCashTransaction(
      String shiftId, String type, double amount, String reason) async {
    final id = _uuid.v4();
    await _db.into(_db.cashTransactions).insert(
          CashTransactionsCompanion.insert(
            id: id,
            shiftId: shiftId,
            type: type,
            amount: amount,
            reason: reason,
            createdAt: DateTime.now(),
            isSynced: const Value(false),
          ),
        );
  }

  @override
  Future<List<domain.CashTransaction>> getCashTransactions(
      String shiftId) async {
    final query = _db.select(_db.cashTransactions)
      ..where((t) => t.shiftId.equals(shiftId));
    final result = await query.get();

    return result
        .map((t) => domain.CashTransaction(
              id: t.id,
              shiftId: t.shiftId,
              type: t.type,
              amount: t.amount,
              reason: t.reason,
              createdAt: t.createdAt,
            ))
        .toList();
  }

  @override
  Future<void> syncShifts(String token) async {
    // 1. Get all unsynced shifts
    final unsyncedShifts = await (_db.select(_db.shifts)
          ..where((t) => t.isSynced.equals(false)))
        .get();

    for (final shift in unsyncedShifts) {
      try {
        // A. Sync Open Shift
        await _remoteDataSource.openShift(token, {
          'id': shift.id,
          'startingCash': shift.startingCash,
          'deviceId': shift.deviceId,
          'startTime': shift.startTime.toIso8601String(),
        });

        // B. Sync Transactions for this shift
        final unsyncedTx = await (_db.select(_db.cashTransactions)
              ..where(
                  (t) => t.shiftId.equals(shift.id) & t.isSynced.equals(false)))
            .get();

        for (final tx in unsyncedTx) {
          await _remoteDataSource.addCashTransaction(token, {
            'shiftId': shift.id,
            'type': tx.type,
            'amount': tx.amount,
            'reason': tx.reason,
          });

          // Mark tx as synced
          await (_db.update(_db.cashTransactions)
                ..where((t) => t.id.equals(tx.id)))
              .write(
            const CashTransactionsCompanion(isSynced: Value(true)),
          );
        }

        // C. Sync Close Shift if needed
        if (shift.status == 'CLOSED') {
          await _remoteDataSource.closeShift(token, shift.id, {
            'shiftId': shift.id,
            'endingCash': shift.endingCash,
            'notes': shift.notes,
          });
        }

        // D. Mark Shift as Synced
        await (_db.update(_db.shifts)..where((t) => t.id.equals(shift.id)))
            .write(
          const ShiftsCompanion(isSynced: Value(true)),
        );
      } catch (e) {
        print('Failed to sync shift ${shift.id}: $e');
      }
    }

    // 2. Sync remaining transactions (e.g. for currently open synced shift)
    final remainingTx = await (_db.select(_db.cashTransactions)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    for (final tx in remainingTx) {
      try {
        await _remoteDataSource.addCashTransaction(token, {
          'shiftId': tx.shiftId,
          'type': tx.type,
          'amount': tx.amount,
          'reason': tx.reason,
        });

        await (_db.update(_db.cashTransactions)
              ..where((t) => t.id.equals(tx.id)))
            .write(
          const CashTransactionsCompanion(isSynced: Value(true)),
        );
      } catch (e) {
        print('Failed to sync transaction ${tx.id}: $e');
      }
    }
  }
}
