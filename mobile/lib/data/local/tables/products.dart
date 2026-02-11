import 'package:drift/drift.dart';

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text()();
  TextColumn get nameEn => text()();
  TextColumn get nameAr => text()();
  RealColumn get price => real()();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  TextColumn get modifierGroups => text().nullable()();
  TextColumn get station => text().nullable()(); // JSON string of station
  TextColumn get course => text().withDefault(const Constant('OTHER'))();
  
  @override
  Set<Column> get primaryKey => {id};
}
