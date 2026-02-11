import '../entities/order.dart';
import '../entities/order_status.dart';
import '../entities/refund.dart';

abstract class OrdersRepository {
  Future<List<Order>> fetchOrders(String token);
  Future<void> updateOrderStatus(
      String token, String orderId, OrderStatus status);
  Future<Order> createOrder(Order order, {String? token});
  Future<void> syncPendingOrders(String token);
  Future<void> fireCourse(String token, String orderId, String course);
  Future<void> assignDriver(String token, String orderId, String driverId);
  Future<List<Order>> getMyDeliveries(String token, String driverId);
  Future<void> requestDelivery(
      String token, String orderId, String providerName);
  Future<void> cancelDelivery(
      String token, String orderId, String providerName);
  Future<void> requestRefund(
      String token, String orderId, double amount, String reason);
  Future<void> approveRefund(String token, String refundId);
  Future<void> rejectRefund(String token, String refundId);
  Future<List<Refund>> fetchPendingRefunds(String token);
  Future<void> voidOrder(
      String token, String orderId, String reason, bool returnStock);
}
