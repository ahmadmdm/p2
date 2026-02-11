import '../entities/user.dart';

abstract class UsersRepository {
  Future<List<User>> getUsers();
  Future<User> createUser(
      String name, String email, String password, String role, String? pinCode);
  Future<User> updateUser(String id,
      {String? name,
      String? email,
      String? password,
      String? role,
      String? pinCode});
  Future<void> deleteUser(String id);
  Future<void> syncUsers(String token);
}
