import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/reports_repository_impl.dart';

part 'reports_controller.g.dart';

@riverpod
Future<Map<String, dynamic>> dailySales(DailySalesRef ref) {
  return ref.watch(reportsRepositoryProvider).getDailySales();
}

@riverpod
Future<List<Map<String, dynamic>>> topProducts(TopProductsRef ref) {
  return ref.watch(reportsRepositoryProvider).getTopProducts();
}

@riverpod
Future<List<Map<String, dynamic>>> lowStockAlerts(LowStockAlertsRef ref) {
  return ref.watch(reportsRepositoryProvider).getLowStockAlerts();
}

@riverpod
Future<List<Map<String, dynamic>>> salesByCategory(SalesByCategoryRef ref) {
  return ref.watch(reportsRepositoryProvider).getSalesByCategory();
}
