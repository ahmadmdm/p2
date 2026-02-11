import 'package:drift/drift.dart';
import 'package:pos_mobile/domain/entities/order.dart' as domain;

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text()();
  TextColumn get role => text()();
  TextColumn get pinCode => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  TextColumn get modifierGroups =>
      text().map(const ModifierGroupsConverter()).nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get tableId => text().nullable()();
  TextColumn get status => text()();
  RealColumn get totalAmount => real()();
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get shiftId => text().nullable().references(Shifts, #id)();

  // Delivery fields
  TextColumn get type => text()
      .withDefault(const Constant('DINE_IN'))(); // DINE_IN, TAKEAWAY, DELIVERY
  RealColumn get deliveryFee => real().withDefault(const Constant(0))();
  TextColumn get deliveryAddress => text().nullable()();
  TextColumn get driverId => text().nullable().references(Users, #id)();
  TextColumn get deliveryProvider =>
      text().nullable()(); // 'uber-eats', 'talabat', 'internal'
  TextColumn get deliveryReferenceId => text().nullable()();

  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class OrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get quantity => integer()();
  RealColumn get price => real()();
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().nullable()();
  TextColumn get modifiers =>
      text().map(const OrderItemModifiersConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Shifts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  RealColumn get startCash => real()();
  RealColumn get endCash => real().nullable()();
  RealColumn get totalSales => real().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class CashTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get shiftId => text().references(Shifts, #id)();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // IN, OUT
  TextColumn get reason => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phoneNumber => text()();
  TextColumn get email => text().nullable()();
  IntColumn get loyaltyPoints => integer().withDefault(const Constant(0))();
  TextColumn get tier => text().withDefault(const Constant('Bronze'))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// Inventory Tables
class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get contactName => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Ingredients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get unit => text()(); // kg, L, pcs
  RealColumn get costPerUnit => real().withDefault(const Constant(0))();
  RealColumn get minLevel => real().withDefault(const Constant(0))();
  RealColumn get currentStock => real().withDefault(const Constant(0))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class RecipeItems extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().nullable().references(Products, #id)();
  // We can also have recipe for modifier items, but for now link to product
  // Or link to a 'menu_item_id' which could be product or modifier_item
  TextColumn get ingredientId => text().references(Ingredients, #id)();
  RealColumn get quantity => real()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseOrders extends Table {
  TextColumn get id => text()();
  TextColumn get supplierId => text().references(Suppliers, #id)();
  DateTimeColumn get orderDate => dateTime()();
  TextColumn get status => text()(); // DRAFT, ORDERED, RECEIVED, CANCELLED
  RealColumn get totalAmount => real()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get paymentDueDate => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseOrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseOrderId => text().references(PurchaseOrders, #id)();
  TextColumn get ingredientId => text().references(Ingredients, #id)();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class Warehouses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  BoolColumn get isMain => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class InventoryItems extends Table {
  TextColumn get id => text()();
  TextColumn get ingredientId => text().references(Ingredients, #id)();
  TextColumn get warehouseId => text().references(Warehouses, #id)();
  RealColumn get quantity => real().withDefault(const Constant(0))();
  RealColumn get minLevel => real().withDefault(const Constant(0))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['UNIQUE(ingredient_id, warehouse_id)'];
}

class InventoryLogs extends Table {
  TextColumn get id => text()();
  TextColumn get ingredientId => text().references(Ingredients, #id)();
  TextColumn get ingredientName => text().nullable()();
  TextColumn get warehouseId => text().nullable().references(Warehouses, #id)();
  TextColumn get warehouseName => text().nullable()();
  RealColumn get quantityChange => real()();
  RealColumn get oldQuantity => real().nullable()();
  RealColumn get newQuantity => real().nullable()();
  TextColumn get reason => text()(); // SALE, WASTE, SPOILAGE, etc.
  TextColumn get notes => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class RestaurantTables extends Table {
  TextColumn get id => text()();
  TextColumn get tableNumber => text()();
  TextColumn get section => text().nullable()();
  IntColumn get capacity => integer().withDefault(const Constant(4))();
  RealColumn get x => real().withDefault(const Constant(0.0))();
  RealColumn get y => real().withDefault(const Constant(0.0))();
  RealColumn get width => real().withDefault(const Constant(100.0))();
  RealColumn get height => real().withDefault(const Constant(100.0))();
  TextColumn get shape => text()
      .withDefault(const Constant('rectangle'))(); // 'rectangle', 'circle'
  RealColumn get rotation => real().withDefault(const Constant(0.0))();
  TextColumn get status => text().withDefault(const Constant('free'))();
  TextColumn get qrCode => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// Type Converters
class ModifierGroupsConverter
    extends TypeConverter<List<domain.ModifierGroup>, String> {
  const ModifierGroupsConverter();

  @override
  List<domain.ModifierGroup> fromSql(String fromDb) {
    // Implement JSON decoding
    return []; // Placeholder - actual implementation needs jsonDecode
  }

  @override
  String toSql(List<domain.ModifierGroup> value) {
    // Implement JSON encoding
    return '[]'; // Placeholder
  }
}

class OrderItemModifiersConverter
    extends TypeConverter<List<domain.OrderItemModifier>, String> {
  const OrderItemModifiersConverter();

  @override
  List<domain.OrderItemModifier> fromSql(String fromDb) {
    return []; // Placeholder
  }

  @override
  String toSql(List<domain.OrderItemModifier> value) {
    return '[]'; // Placeholder
  }
}
