import 'package:fpdart/fpdart.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<String, User>> login(String email, String password);
  Future<Either<String, User>> loginWithPin(String pin);
  Future<void> logout();
  Future<Option<User>> getCurrentUser();
}
