abstract class ReportsRepository {
  Future<Map<String, dynamic>> getDailySales();
  Future<List<Map<String, dynamic>>> getTopProducts();
  Future<List<Map<String, dynamic>>> getLowStockAlerts();
  Future<List<Map<String, dynamic>>> getSalesByCategory();
}
