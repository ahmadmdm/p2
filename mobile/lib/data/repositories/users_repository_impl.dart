import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/users_repository.dart';
import '../datasources/remote/users_remote_datasource.dart';
import '../../presentation/features/auth/auth_controller.dart';
import '../datasources/local/database.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepositoryImpl(
    ref.watch(usersRemoteDataSourceProvider),
    ref.watch(appDatabaseProvider),
    ref,
  );
});

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource _remoteDataSource;
  final AppDatabase _db;
  final Ref _ref;

  UsersRepositoryImpl(this._remoteDataSource, this._db, this._ref);

  String? get _token => _ref.read(authControllerProvider).value?.accessToken;

  @override
  Future<List<domain.User>> getUsers() async {
    if (_token != null) {
      await syncUsers(_token!);
    }

    final localUsers = await _db.select(_db.users).get();
    return localUsers
        .map((u) => domain.User(
              id: u.id,
              name: u.name,
              email: u.email,
              role: u.role,
              pinCode: u.pinCode,
            ))
        .toList();
  }

  @override
  Future<void> syncUsers(String token) async {
    final data = await _remoteDataSource.getUsers(token);
    final users = data.map((json) => domain.User.fromJson(json)).toList();

    await _db.batch((batch) {
      for (final u in users) {
        batch.insert(
          _db.users,
          UsersCompanion(
            id: Value(u.id),
            name: Value(u.name),
            email: Value(u.email),
            role: Value(u.role),
            pinCode: Value(u.pinCode),
            isActive: const Value(true),
            isSynced: const Value(true),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  @override
  Future<domain.User> createUser(
    String name,
    String email,
    String password,
    String role,
    String? pinCode,
  ) async {
    final token = _token;
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final body = {
      'name': name,
      'email': email,
      'passwordHash': password,
      'role': role,
      'pinCode': pinCode,
    };
    final data = await _remoteDataSource.createUser(token, body);
    final user = domain.User.fromJson(data);

    await _db.into(_db.users).insertOnConflictUpdate(
          UsersCompanion(
            id: Value(user.id),
            name: Value(user.name),
            email: Value(user.email),
            role: Value(user.role),
            pinCode: Value(user.pinCode),
            isActive: const Value(true),
            isSynced: const Value(true),
          ),
        );

    return user;
  }

  @override
  Future<domain.User> updateUser(
    String id, {
    String? name,
    String? email,
    String? password,
    String? role,
    String? pinCode,
  }) async {
    final token = _token;
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (password != null) body['passwordHash'] = password;
    if (role != null) body['role'] = role;
    if (pinCode != null) body['pinCode'] = pinCode;

    final data = await _remoteDataSource.updateUser(token, id, body);
    final user = domain.User.fromJson(data);

    await _db.into(_db.users).insertOnConflictUpdate(
          UsersCompanion(
            id: Value(user.id),
            name: Value(user.name),
            email: Value(user.email),
            role: Value(user.role),
            pinCode: Value(user.pinCode),
            isActive: const Value(true),
            isSynced: const Value(true),
          ),
        );

    return user;
  }

  @override
  Future<void> deleteUser(String id) async {
    final token = _token;
    if (token == null) {
      throw Exception('Not authenticated');
    }
    await _remoteDataSource.deleteUser(token, id);
    await (_db.delete(_db.users)..where((t) => t.id.equals(id))).go();
  }
}
