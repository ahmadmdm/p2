import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/customer.dart';
import '../../../data/repositories/customers_repository_impl.dart';

part 'customers_controller.g.dart';

@riverpod
class CustomersController extends _$CustomersController {
  @override
  FutureOr<List<Customer>> build() async {
    return ref.read(customersRepositoryProvider).searchCustomers('');
  }

  Future<void> addCustomer(String name, String phoneNumber) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(customersRepositoryProvider).createCustomer(name, phoneNumber);
      return ref.read(customersRepositoryProvider).searchCustomers('');
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(customersRepositoryProvider).searchCustomers('');
    });
  }
}
