import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/order.dart';
import '../../../data/repositories/orders_repository_impl.dart';
import '../../features/auth/auth_controller.dart';
import '../../../domain/entities/order_status.dart';

part 'my_deliveries_controller.g.dart';

@riverpod
class MyDeliveriesController extends _$MyDeliveriesController {
  @override
  Future<List<Order>> build() async {
    final user = ref.watch(authControllerProvider).value;
    if (user == null || user.role != 'driver') {
      return [];
    }
    final repository = ref.watch(ordersRepositoryProvider);
    // If offline, we might want to get local assigned orders?
    // But repository.getMyDeliveries fetches from remote.
    // For now, assume online for driver app functions or sync logic needs to be enhanced.
    if (user.accessToken == null) return [];
    
    return repository.getMyDeliveries(user.accessToken!, user.id);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authControllerProvider).value;
      if (user == null || user.role != 'driver') return [];
      final repository = ref.read(ordersRepositoryProvider);
      return repository.getMyDeliveries(user.accessToken!, user.id);
    });
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    final user = ref.read(authControllerProvider).value;
    if (user == null || user.accessToken == null) return;

    final repository = ref.read(ordersRepositoryProvider);
    await repository.updateOrderStatus(user.accessToken!, orderId, status);
    
    // Refresh list
    ref.invalidateSelf();
  }
}
