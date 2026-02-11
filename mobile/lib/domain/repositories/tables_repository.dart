import '../entities/restaurant_table.dart';

abstract class TablesRepository {
  Future<List<RestaurantTable>> getTables();
  Future<void> updateLayout(List<RestaurantTable> tables);
}
