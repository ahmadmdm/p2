import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/order.dart';

abstract class KitchenRepository {
  Future<Either<Failure, List<dynamic>>> getStations();
  Future<Either<Failure, dynamic>> createStation(
      String name, String? printerName);
  Future<Either<Failure, List<Order>>> getKdsOrders(String? stationId);
  Future<Either<Failure, void>> updateItemStatus(String itemId, String status);
  Future<Either<Failure, void>> updateOrderStatus(
      String orderId, String status);
}
