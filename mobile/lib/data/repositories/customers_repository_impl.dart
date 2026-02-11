import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/customer.dart' as domain;
import '../../domain/repositories/customers_repository.dart';
import '../datasources/remote/customers_remote_datasource.dart';
import '../datasources/local/database.dart';
import '../../presentation/features/auth/auth_controller.dart';

import 'package:uuid/uuid.dart';
import '../../domain/entities/loyalty_transaction.dart';

part 'customers_repository_impl.g.dart';

@riverpod
CustomersRepository customersRepository(CustomersRepositoryRef ref) {
  final remoteDataSource = ref.watch(customersRemoteDataSourceProvider);
  final db = ref.watch(appDatabaseProvider);
  return CustomersRepositoryImpl(remoteDataSource, db, ref);
}

class CustomersRepositoryImpl implements CustomersRepository {
  final CustomersRemoteDataSource _remoteDataSource;
  final AppDatabase _db;
  final CustomersRepositoryRef _ref;

  CustomersRepositoryImpl(this._remoteDataSource, this._db, this._ref);

  @override
  Future<List<domain.Customer>> searchCustomers(String query) async {
    final user = _ref.read(authControllerProvider).value;
    final token = user?.accessToken;

    if (token != null) {
      try {
        final data = await _remoteDataSource.searchCustomers(token, query);
        final remoteCustomers =
            data.map((json) => domain.Customer.fromJson(json)).toList();

        // Cache to local DB
        await _db.batch((batch) {
          for (final customer in remoteCustomers) {
            batch.insert(
                _db.customers,
                CustomersCompanion.insert(
                  id: customer.id,
                  name: customer.name,
                  phoneNumber: customer.phoneNumber,
                  loyaltyPoints: Value(customer.loyaltyPoints),
                  tier: Value(customer.tier),
                  isSynced: const Value(true),
                ),
                mode: InsertMode.insertOrReplace);
          }
        });

        return remoteCustomers;
      } catch (e) {
        print('Remote search failed: $e');
        // Fallback to local
      }
    }

    // Local Search
    final result = await (_db.select(_db.customers)
          ..where((tbl) =>
              tbl.name.contains(query) | tbl.phoneNumber.contains(query)))
        .get();

    return result
        .map((c) => domain.Customer(
              id: c.id,
              name: c.name,
              phoneNumber: c.phoneNumber,
              loyaltyPoints: c.loyaltyPoints,
              tier: c.tier,
            ))
        .toList();
  }

  @override
  Future<domain.Customer> createCustomer(String name, String phone) async {
    final user = _ref.read(authControllerProvider).value;
    final token = user?.accessToken;
    final id = const Uuid().v4();

    if (token != null) {
      try {
        final data = await _remoteDataSource.createCustomer(token, {
          'id': id,
          'name': name,
          'phoneNumber': phone,
        });
        final newCustomer = domain.Customer.fromJson(data);

        // Save to local
        await _db.into(_db.customers).insert(
            CustomersCompanion.insert(
              id: newCustomer.id,
              name: newCustomer.name,
              phoneNumber: newCustomer.phoneNumber,
              loyaltyPoints: Value(newCustomer.loyaltyPoints),
              tier: Value(newCustomer.tier),
              isSynced: const Value(true),
            ),
            mode: InsertMode.insertOrReplace);

        return newCustomer;
      } catch (e) {
        print('Remote create failed: $e');
      }
    }

    // Offline Creation (or fallback)
    final localCustomer = domain.Customer(
        id: id, name: name, phoneNumber: phone, loyaltyPoints: 0);

    await _db.into(_db.customers).insert(
        CustomersCompanion.insert(
          id: id,
          name: name,
          phoneNumber: phone,
          loyaltyPoints: const Value(0),
          isSynced: const Value(false),
        ),
        mode: InsertMode.insertOrReplace);

    return localCustomer;
  }

  @override
  Future<void> syncCustomers(String token) async {
    final unsynced = await (_db.select(_db.customers)
          ..where((tbl) => tbl.isSynced.equals(false)))
        .get();

    for (final local in unsynced) {
      try {
        await _remoteDataSource.createCustomer(token, {
          'id': local.id,
          'name': local.name,
          'phoneNumber': local.phoneNumber,
        });

        // Mark as synced
        await (_db.update(_db.customers)
              ..where((tbl) => tbl.id.equals(local.id)))
            .write(const CustomersCompanion(
          isSynced: Value(true),
        ));
      } catch (e) {
        print('Failed to sync customer ${local.id}: $e');
      }
    }
  }

  @override
  Future<List<LoyaltyTransaction>> getLoyaltyHistory(String customerId) async {
    final user = _ref.read(authControllerProvider).value;
    final token = user?.accessToken;

    if (token != null) {
      try {
        final data =
            await _remoteDataSource.getLoyaltyHistory(token, customerId);
        return data.map((json) => LoyaltyTransaction.fromJson(json)).toList();
      } catch (e) {
        print('Failed to fetch loyalty history: $e');
      }
    }
    return [];
  }
}
