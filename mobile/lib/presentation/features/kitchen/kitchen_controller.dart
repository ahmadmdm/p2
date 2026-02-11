import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/order_status.dart';
import '../../../data/repositories/kitchen_repository_impl.dart';
import '../../core/services/kitchen_socket_service.dart';
import '../auth/auth_controller.dart';

part 'kitchen_controller.g.dart';

@riverpod
class KitchenController extends _$KitchenController {
  @override
  FutureOr<List<Order>> build(String? stationId) async {
    // Listen to socket updates
    final socketService = ref.watch(kitchenSocketServiceProvider);
    final sub = socketService.onOrderUpdate.listen((_) {
      ref.invalidateSelf();
    });
    ref.onDispose(() => sub.cancel());

    return _fetchOrders(stationId);
  }

  Future<List<Order>> _fetchOrders(String? stationId) async {
    final result =
        await ref.read(kitchenRepositoryProvider).getKdsOrders(stationId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (orders) => orders,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchOrders(stationId));
  }

  Future<void> updateItemStatus(String itemId, String status) async {
    try {
      final result = await ref
          .read(kitchenRepositoryProvider)
          .updateItemStatus(itemId, status);
      result.fold(
        (failure) => throw Exception(failure.message),
        (_) async {
          // Optimistic update or refresh
          await refresh();
        },
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    try {
      final result = await ref
          .read(kitchenRepositoryProvider)
          .updateOrderStatus(orderId, status.name);
      result.fold(
        (failure) => throw Exception(failure.message),
        (_) async {
          await refresh();
        },
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

@riverpod
Future<List<dynamic>> stations(StationsRef ref) async {
  final result = await ref.read(kitchenRepositoryProvider).getStations();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stations) => stations,
  );
}
