import '../entities/customer.dart';
import '../entities/loyalty_transaction.dart';

abstract class CustomersRepository {
  Future<List<Customer>> searchCustomers(String query);
  Future<Customer> createCustomer(String name, String phone);
  Future<void> syncCustomers(String token);
  Future<List<LoyaltyTransaction>> getLoyaltyHistory(String customerId);
}
