import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/order.dart';
import '../../../data/repositories/orders_repository_impl.dart';
import '../auth/auth_controller.dart';

part 'orders_history_controller.g.dart';

@riverpod
Future<List<Order>> ordersHistory(OrdersHistoryRef ref) async {
  final repository = ref.watch(ordersRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  final token = authState.value?.accessToken;
  
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
      final accessToken = ref.read(authControllerProvider).value!.accessToken ?? '';
      await ref.read(ordersRepositoryProvider).requestRefund(accessToken, orderId, amount, reason);
      ref.invalidate(ordersHistoryProvider);
    });
  }

  Future<void> approveRefund(String refundId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final accessToken = ref.read(authControllerProvider).value!.accessToken ?? '';
      await ref.read(ordersRepositoryProvider).approveRefund(accessToken, refundId);
      ref.invalidate(ordersHistoryProvider);
    });
  }

  Future<void> voidOrder(String orderId, String reason, bool returnStock) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final accessToken = ref.read(authControllerProvider).value!.accessToken ?? '';
      await ref.read(ordersRepositoryProvider).voidOrder(accessToken, orderId, reason, returnStock);
      ref.invalidate(ordersHistoryProvider);
    });
  }
}
