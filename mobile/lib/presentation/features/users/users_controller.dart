import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/user.dart';
import '../../../data/repositories/users_repository_impl.dart';

part 'users_controller.g.dart';

@riverpod
class UsersController extends _$UsersController {
  @override
  Future<List<User>> build() async {
    final repository = ref.watch(usersRepositoryProvider);
    return repository.getUsers();
  }

  Future<void> addUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? pinCode,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(usersRepositoryProvider);
      await repository.createUser(name, email, password, role, pinCode);
      return repository.getUsers();
    });
  }

  Future<void> updateUser(String id, {
    String? name,
    String? email,
    String? password,
    String? role,
    String? pinCode,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(usersRepositoryProvider);
      await repository.updateUser(id, name: name, email: email, password: password, role: role, pinCode: pinCode);
      return repository.getUsers();
    });
  }

  Future<void> deleteUser(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(usersRepositoryProvider);
      await repository.deleteUser(id);
      return repository.getUsers();
    });
  }
}
