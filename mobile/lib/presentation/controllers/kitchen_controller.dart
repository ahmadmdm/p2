import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/order.dart';
import '../../../data/repositories/kitchen_repository_impl.dart';

part 'kitchen_controller.g.dart';

@riverpod
class KitchenController extends _$KitchenController {
  @override
  FutureOr<List<Order>> build(String? stationId) async {
    return _fetchOrders(stationId);
  }

  Future<List<Order>> _fetchOrders(String? stationId) async {
    final repository = ref.read(kitchenRepositoryProvider);
    final result = await repository.getKdsOrders(stationId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (orders) => List<Order>.from(orders),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchOrders(stationId));
  }

  Future<void> updateItemStatus(String itemId, String status) async {
    final repository = ref.read(kitchenRepositoryProvider);
    final result = await repository.updateItemStatus(itemId, status);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => refresh(),
    );
  }
}

@riverpod
Future<List<dynamic>> stations(StationsRef ref) async {
  final repository = ref.read(kitchenRepositoryProvider);
  final result = await repository.getStations();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stations) => stations,
  );
}
