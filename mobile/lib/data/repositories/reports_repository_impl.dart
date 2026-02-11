import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/remote/reports_remote_datasource.dart';
import '../../presentation/features/auth/auth_controller.dart';

part 'reports_repository_impl.g.dart';

@riverpod
ReportsRepository reportsRepository(ReportsRepositoryRef ref) {
  return ReportsRepositoryImpl(
    ref.watch(reportsRemoteDataSourceProvider),
    ref,
  );
}

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource _remoteDataSource;
  final ReportsRepositoryRef _ref;

  ReportsRepositoryImpl(this._remoteDataSource, this._ref);

  String? get _token => _ref.read(authControllerProvider).value?.accessToken;

  @override
  Future<Map<String, dynamic>> getDailySales() async {
    if (_token == null) throw Exception('Not authenticated');
    final data = await _remoteDataSource.getDailySales(_token!);
    return Map<String, dynamic>.from(data);
  }

  @override
  Future<List<Map<String, dynamic>>> getTopProducts() async {
    if (_token == null) throw Exception('Not authenticated');
    final data = await _remoteDataSource.getTopProducts(_token!);
    return List<Map<String, dynamic>>.from(
        data.map((x) => Map<String, dynamic>.from(x)));
  }

  @override
  Future<List<Map<String, dynamic>>> getLowStockAlerts() async {
    if (_token == null) throw Exception('Not authenticated');
    final data = await _remoteDataSource.getLowStockAlerts(_token!);
    return List<Map<String, dynamic>>.from(
        data.map((x) => Map<String, dynamic>.from(x)));
  }

  @override
  Future<List<Map<String, dynamic>>> getSalesByCategory() async {
    if (_token == null) throw Exception('Not authenticated');
    final data = await _remoteDataSource.getSalesByCategory(_token!);
    return List<Map<String, dynamic>>.from(
        data.map((x) => Map<String, dynamic>.from(x)));
  }
}
