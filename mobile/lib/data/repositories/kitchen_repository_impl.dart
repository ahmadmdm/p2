import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../domain/repositories/kitchen_repository.dart';
import '../../domain/entities/order.dart';
import '../datasources/remote/kitchen_remote_datasource.dart';

part 'kitchen_repository_impl.g.dart';

@riverpod
KitchenRepository kitchenRepository(KitchenRepositoryRef ref) {
  return KitchenRepositoryImpl(ref.read(kitchenRemoteDataSourceProvider));
}

class KitchenRepositoryImpl implements KitchenRepository {
  final KitchenRemoteDataSource _remoteDataSource;

  KitchenRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<dynamic>>> getStations() async {
    try {
      final result = await _remoteDataSource.getStations();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, dynamic>> createStation(
      String name, String? printerName) async {
    try {
      final result = await _remoteDataSource.createStation(name, printerName);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getKdsOrders(String? stationId) async {
    try {
      final result = await _remoteDataSource.getKdsOrders(stationId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateItemStatus(
      String itemId, String status) async {
    try {
      await _remoteDataSource.updateItemStatus(itemId, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(
      String orderId, String status) async {
    try {
      await _remoteDataSource.updateOrderStatus(orderId, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
