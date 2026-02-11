import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  TextColumn get role => text()(); // admin, manager, cashier, waiter, kitchen, driver
  TextColumn get pinCode => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}
