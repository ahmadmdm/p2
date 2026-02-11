import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/shift.dart';
import '../../domain/repositories/shifts_repository.dart';
import '../../data/repositories/shifts_repository_impl.dart';
import '../auth/auth_controller.dart';

part 'shifts_controller.g.dart';

@riverpod
class ShiftsController extends _$ShiftsController {
  @override
  Future<Shift?> build() async {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return null;
    return ref.watch(shiftsRepositoryProvider).getOpenShift(user.id);
  }

  Future<void> openShift(double startingCash) async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    await ref
        .read(shiftsRepositoryProvider)
        .openShift(user.id, startingCash, null);
    ref.invalidateSelf();
  }

  Future<void> closeShift(double endingCash, String? notes) async {
    final shift = state.value;
    if (shift == null) return;

    await ref
        .read(shiftsRepositoryProvider)
        .closeShift(shift.id, endingCash, notes);
    ref.invalidateSelf();
  }

  Future<void> addCashTransaction(
      String type, double amount, String reason) async {
    final shift = state.value;
    if (shift == null) return;

    await ref
        .read(shiftsRepositoryProvider)
        .addCashTransaction(shift.id, type, amount, reason);
  }
}
