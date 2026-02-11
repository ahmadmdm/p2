import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/order.dart';
import '../../../data/repositories/orders_repository_impl.dart';
import '../auth/auth_controller.dart';

part 'delivery_orders_controller.g.dart';

@riverpod
class DeliveryOrdersController extends _$DeliveryOrdersController {
  @override
  FutureOr<List<Order>> build() async {
    final authState = ref.read(authControllerProvider);
    final token = authState.value?.accessToken;
    if (token == null) return [];

    // Ideally we should have a stream or polling, but for now fetch once/refresh
    // We reuse the repository fetchOrders which gets all orders
    // In a real app, we might want a specific endpoint for delivery orders
    return ref.read(ordersRepositoryProvider).fetchOrders(token);
  }

  Future<void> assignDriver(String orderId, String driverId) async {
    final authState = ref.read(authControllerProvider);
    final token = authState.value?.accessToken;
    if (token == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(ordersRepositoryProvider)
          .assignDriver(token, orderId, driverId);
      // Refresh list
      return _fetchOrders();
    });
  }

  Future<void> requestExternalDelivery(
      String orderId, String providerName) async {
    final authState = ref.read(authControllerProvider);
    final token = authState.value?.accessToken;
    if (token == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(ordersRepositoryProvider)
          .requestDelivery(token, orderId, providerName);
      // Refresh list
      return _fetchOrders();
    });
  }

  Future<List<Order>> _fetchOrders() async {
    final authState = ref.read(authControllerProvider);
    final token = authState.value?.accessToken;
    if (token == null) return [];
    return ref.read(ordersRepositoryProvider).fetchOrders(token);
  }
}
