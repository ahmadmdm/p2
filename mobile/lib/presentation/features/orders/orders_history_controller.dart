import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/order.dart';
import '../../../data/repositories/orders_repository_impl.dart';
import '../../auth/auth_controller.dart';

part 'orders_history_controller.g.dart';

@riverpod
Future<List<Order>> ordersHistory(OrdersHistoryRef ref) async {
  final repository = ref.watch(ordersRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  final token = authState.value?.token;
  
  // Even if token is null, repository might return local orders
  return repository.fetchOrders(token ?? '');
}

@riverpod
class OrdersActionsController extends _$OrdersActionsController {
  @override
  FutureOr<void> build() {}

  Future<void> requestRefund(String orderId, double amount, String reason) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final token = ref.read(authControllerProvider).value!.token;
      await ref.read(ordersRepositoryProvider).requestRefund(token, orderId, amount, reason);
      ref.invalidate(ordersHistoryProvider);
    });
  }

  Future<void> approveRefund(String refundId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final token = ref.read(authControllerProvider).value!.token;
      await ref.read(ordersRepositoryProvider).approveRefund(token, refundId);
      ref.invalidate(ordersHistoryProvider);
    });
  }

  Future<void> voidOrder(String orderId, String reason, bool returnStock) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final token = ref.read(authControllerProvider).value!.token;
      await ref.read(ordersRepositoryProvider).voidOrder(token, orderId, reason, returnStock);
      ref.invalidate(ordersHistoryProvider);
    });
  }
}
