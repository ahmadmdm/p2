import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/refund.dart';
import '../../../domain/repositories/orders_repository.dart';
import '../../auth/auth_controller.dart';
import '../../../data/repositories/orders_repository_impl.dart';

part 'refunds_approval_controller.g.dart';

@riverpod
Future<List<Refund>> pendingRefunds(PendingRefundsRef ref) async {
  final repository = ref.watch(ordersRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  final token = authState.value?.token;

  if (token == null) return [];

  return repository.fetchPendingRefunds(token);
}

@riverpod
class RefundsActionsController extends _$RefundsActionsController {
  @override
  FutureOr<void> build() {}

  Future<void> approveRefund(String refundId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final token = ref.read(authControllerProvider).value!.token;
      await ref.read(ordersRepositoryProvider).approveRefund(token, refundId);
      ref.invalidate(pendingRefundsProvider);
    });
  }

  Future<void> rejectRefund(String refundId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final token = ref.read(authControllerProvider).value!.token;
      await ref.read(ordersRepositoryProvider).rejectRefund(token, refundId);
      ref.invalidate(pendingRefundsProvider);
    });
  }
}
