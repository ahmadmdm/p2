import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/restaurant_table.dart';
import '../../../data/repositories/tables_repository_impl.dart';
import '../../core/services/kitchen_socket_service.dart';

part 'tables_controller.g.dart';

@riverpod
class TablesController extends _$TablesController {
  @override
  FutureOr<List<RestaurantTable>> build() async {
    // Listen to socket updates for real-time table status
    final socketService = ref.watch(kitchenSocketServiceProvider);
    final sub = socketService.onTableUpdate.listen((_) {
      ref.invalidateSelf();
    });
    ref.onDispose(() => sub.cancel());

    return ref.read(tablesRepositoryProvider).getTables();
  }

  Future<void> saveLayout(List<RestaurantTable> tables) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(tablesRepositoryProvider).updateLayout(tables);
      return tables;
    });
  }

  void updateTableLocally(RestaurantTable updatedTable) {
    final currentTables = state.value ?? [];
    final index = currentTables.indexWhere((t) => t.id == updatedTable.id);
    if (index != -1) {
      final newTables = List<RestaurantTable>.from(currentTables);
      newTables[index] = updatedTable;
      state = AsyncValue.data(newTables);
    }
  }

  void addTableLocally(RestaurantTable newTable) {
    final currentTables = state.value ?? [];
    final newTables = [...currentTables, newTable];
    state = AsyncValue.data(newTables);
  }

  void removeTableLocally(String tableId) {
    final currentTables = state.value ?? [];
    final newTables = currentTables.where((t) => t.id != tableId).toList();
    state = AsyncValue.data(newTables);
  }
}
