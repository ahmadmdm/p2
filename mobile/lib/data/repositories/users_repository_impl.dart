import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../domain/entities/user.dart';
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
  Future<List<User>> getUsers() async {
    if (_token != null) {
      try {
        await syncUsers(_token!);
      } catch (e) {
        print('Error syncing users: $e');
      }
    }

    // Always return from local DB for consistency
    final localUsers = await _db.select(_db.users).get();
    return localUsers
        .map((u) => User(
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
    final users = data.map((json) => User.fromJson(json)).toList();

    await _db.batch((batch) {
      for (final u in users) {
        batch.insertOnConflictUpdate(
          _db.users,
          UsersCompanion(
            id: Value(u.id),
            name: Value(u.name),
            email: Value(u.email),
            role: Value(u.role),
            pinCode: Value(u.pinCode),
            isActive: const Value(true),
          ),
        );
      }
    });
  }

  @override
  Future<User> createUser(String name, String email, String password,
      String role, String? pinCode) async {
    if (_token == null) throw Exception('Not authenticated');

    final body = {
      'name': name,
      'email': email,
      'passwordHash': password,
      'role': role,
      'pinCode': pinCode,
    };
    final data = await _remoteDataSource.createUser(_token!, body);
    final user = User.fromJson(data);

    // Save to local
    await _db.into(_db.users).insertOnConflictUpdate(UsersCompanion(
          id: Value(user.id),
          name: Value(user.name),
          email: Value(user.email),
          role: Value(user.role),
          pinCode: Value(user.pinCode),
        ));

    return user;
  }

  @override
  Future<User> updateUser(String id,
      {String? name,
      String? email,
      String? password,
      String? role,
      String? pinCode}) async {
    if (_token == null) throw Exception('Not authenticated');

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (password != null) body['passwordHash'] = password;
    if (role != null) body['role'] = role;
    if (pinCode != null) body['pinCode'] = pinCode;

    final data = await _remoteDataSource.updateUser(_token!, id, body);
    final user = User.fromJson(data);

    // Save to local
    await _db.into(_db.users).insertOnConflictUpdate(UsersCompanion(
          id: Value(user.id),
          name: Value(user.name),
          email: Value(user.email),
          role: Value(user.role),
          pinCode: Value(user.pinCode),
        ));

    return user;
  }

  @override
  Future<void> deleteUser(String id) async {
    if (_token == null) throw Exception('Not authenticated');
    await _remoteDataSource.deleteUser(_token!, id);
    await (_db.delete(_db.users)..where((t) => t.id.equals(id))).go();
  }
}
