import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../datasources/local/database.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(appDatabaseProvider),
  );
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AppDatabase _db;

  AuthRepositoryImpl(this._remoteDataSource, this._db);

  @override
  Future<Either<String, domain.User>> login(
      String email, String password) async {
    try {
      final result = await _remoteDataSource.login(email, password);
      final userData = result['user'];
      final token = result['access_token'];

      final user = domain.User(
        id: userData['id'],
        email: userData['email'],
        name: userData['name'],
        role: userData['role'],
        accessToken: token,
      );

      // Save to local DB
      await _db.into(_db.users).insertOnConflictUpdate(UsersCompanion.insert(
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
          ));

      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, domain.User>> loginWithPin(String pin) async {
    try {
      final user = await (_db.select(_db.users)
            ..where((t) => t.pinCode.equals(pin)))
          .getSingleOrNull();

      if (user == null) {
        return const Left('Invalid PIN');
      }

      return Right(domain.User(
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        accessToken: '', // Offline login implies no token or token needs refreshing
        pinCode: user.pinCode,
      ));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    // TODO: Clear token
  }

  @override
  Future<Option<domain.User>> getCurrentUser() async {
    // TODO: Check local storage for token/user
    return const None();
  }
}
