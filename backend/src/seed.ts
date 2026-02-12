
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as bcrypt from 'bcrypt';
import { DataSource, IsNull, Repository } from 'typeorm';
import { User, UserRole } from './modules/users/user.entity';
import { Station } from './modules/kitchen/station.entity';
import { Category } from './modules/catalog/category.entity';
import { Product } from './modules/catalog/product.entity';
import { Table, TableShape, TableStatus } from './modules/tables/table.entity';
import { Customer } from './modules/customers/customer.entity';
import { Coupon, CouponType } from './modules/customers/coupon.entity';
import { Warehouse } from './modules/inventory/warehouse.entity';
import { Ingredient } from './modules/inventory/ingredient.entity';
import { InventoryItem } from './modules/inventory/inventory-item.entity';
import { RecipeItem } from './modules/inventory/recipe-item.entity';
import { Supplier } from './modules/suppliers/supplier.entity';
import {
  PurchaseOrder,
  PurchaseOrderStatus,
} from './modules/purchasing/purchase-order.entity';
import { PurchaseOrderItem } from './modules/purchasing/purchase-order-item.entity';
import {
  Order,
  OrderStatus,
  OrderType,
  PaymentMethod,
  PaymentStatus,
} from './modules/orders/order.entity';
import { OrderItem } from './modules/orders/order-item.entity';
import { Refund } from './modules/orders/refund.entity';
import { Shift, ShiftStatus } from './modules/shifts/shift.entity';
import {
  CashTransaction,
  TransactionType,
} from './modules/shifts/cash-transaction.entity';

async function findByEn(repo: Repository<any>, alias: string, en: string) {
  return repo
    .createQueryBuilder(alias)
    .where(`${alias}.name ->> 'en' = :en`, { en })
    .getOne();
}

async function ensureUser(repo: Repository<User>, data: {
  email: string;
  password: string;
  name: string;
  role: UserRole;
  pinCode: string;
}) {
  const existing = await repo
    .createQueryBuilder('user')
    .addSelect('user.passwordHash')
    .where('user.email = :email', { email: data.email })
    .getOne();

  const passwordHash = await bcrypt.hash(data.password, 10);
  if (existing) {
    existing.name = data.name;
    existing.role = data.role;
    existing.pinCode = data.pinCode;
    existing.passwordHash = passwordHash;
    existing.isActive = true;
    return repo.save(existing);
  }

  return repo.save(
    repo.create({
      email: data.email,
      name: data.name,
      role: data.role,
      pinCode: data.pinCode,
      passwordHash,
      isActive: true,
    }),
  );
}

async function ensureRecipe(
  repo: Repository<RecipeItem>,
  ingredientId: string,
  quantity: number,
  productId?: string,
) {
  const where: any = {
    ingredient: { id: ingredientId },
    product: productId ? { id: productId } : IsNull(),
    modifierItem: IsNull(),
  };

  const existing = await repo.findOne({ where, relations: ['ingredient', 'product'] });
  if (existing) {
    existing.quantity = quantity;
    return repo.save(existing);
  }

  return repo.save(
    repo.create({
      ingredient: { id: ingredientId } as Ingredient,
      product: productId ? ({ id: productId } as Product) : null,
      modifierItem: null,
      quantity,
    }),
  );
}

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['error', 'warn', 'log'],
  });

  try {
    const db = app.get(DataSource);

    const usersRepo = db.getRepository(User);
    const stationsRepo = db.getRepository(Station);
    const categoriesRepo = db.getRepository(Category);
    const productsRepo = db.getRepository(Product);
    const tablesRepo = db.getRepository(Table);
    const customersRepo = db.getRepository(Customer);
    const couponsRepo = db.getRepository(Coupon);
    const warehousesRepo = db.getRepository(Warehouse);
    const ingredientsRepo = db.getRepository(Ingredient);
    const inventoryRepo = db.getRepository(InventoryItem);
    const recipesRepo = db.getRepository(RecipeItem);
    const suppliersRepo = db.getRepository(Supplier);
    const poRepo = db.getRepository(PurchaseOrder);
    const poItemRepo = db.getRepository(PurchaseOrderItem);
    const ordersRepo = db.getRepository(Order);
    const orderItemsRepo = db.getRepository(OrderItem);
    const refundsRepo = db.getRepository(Refund);
    const shiftsRepo = db.getRepository(Shift);
    const cashTxRepo = db.getRepository(CashTransaction);

    console.log('Seeding test data...');

    const users = [
      await ensureUser(usersRepo, {
        email: 'admin@pos.com',
        password: 'admin123',
        name: 'System Admin',
        role: UserRole.ADMIN,
        pinCode: '1111',
      }),
      await ensureUser(usersRepo, {
        email: 'manager@pos.com',
        password: 'manager123',
        name: 'Store Manager',
        role: UserRole.MANAGER,
        pinCode: '2222',
      }),
      await ensureUser(usersRepo, {
        email: 'cashier@pos.com',
        password: 'cashier123',
        name: 'Front Cashier',
        role: UserRole.CASHIER,
        pinCode: '3333',
      }),
      await ensureUser(usersRepo, {
        email: 'waiter@pos.com',
        password: 'waiter123',
        name: 'Dining Waiter',
        role: UserRole.WAITER,
        pinCode: '4444',
      }),
      await ensureUser(usersRepo, {
        email: 'kitchen@pos.com',
        password: 'kitchen123',
        name: 'Kitchen Staff',
        role: UserRole.KITCHEN,
        pinCode: '5555',
      }),
      await ensureUser(usersRepo, {
        email: 'driver@pos.com',
        password: 'driver123',
        name: 'Delivery Driver',
        role: UserRole.DRIVER,
        pinCode: '6666',
      }),
    ];

    const usersByEmail = new Map(users.map((u) => [u.email, u]));

    const stationsSeed = [
      { name: 'Hot Kitchen', printerName: 'Kitchen Printer' },
      { name: 'Bar', printerName: 'Bar Printer' },
      { name: 'Dessert', printerName: 'Dessert Printer' },
    ];
    const stationsByName = new Map<string, Station>();
    for (const s of stationsSeed) {
      let station = await stationsRepo.findOne({ where: { name: s.name } });
      if (!station) station = stationsRepo.create(s);
      station.printerPort = 9100;
      stationsByName.set(s.name, await stationsRepo.save(station));
    }

    const categoriesSeed = [
      { en: 'Starters', ar: 'Starters', sortOrder: 1 },
      { en: 'Mains', ar: 'Mains', sortOrder: 2 },
      { en: 'Desserts', ar: 'Desserts', sortOrder: 3 },
      { en: 'Drinks', ar: 'Drinks', sortOrder: 4 },
    ];

    const categoriesByEn = new Map<string, Category>();
    for (const c of categoriesSeed) {
      let category = await findByEn(categoriesRepo, 'category', c.en);
      if (!category) category = categoriesRepo.create({ name: { en: c.en, ar: c.ar } });
      category.name = { en: c.en, ar: c.ar };
      category.sortOrder = c.sortOrder;
      categoriesByEn.set(c.en, await categoriesRepo.save(category));
    }

    const productsSeed = [
      {
        en: 'Caesar Salad',
        ar: 'Caesar Salad',
        category: 'Starters',
        price: 19.5,
        course: 'STARTER',
        station: 'Hot Kitchen',
        imageUrl:
          'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=1200&auto=format&fit=crop',
      },
      {
        en: 'Tomato Soup',
        ar: 'Tomato Soup',
        category: 'Starters',
        price: 14,
        course: 'STARTER',
        station: 'Hot Kitchen',
        imageUrl:
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=1200&auto=format&fit=crop',
      },
      {
        en: 'Classic Burger',
        ar: 'Classic Burger',
        category: 'Mains',
        price: 34,
        course: 'MAIN',
        station: 'Hot Kitchen',
        imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=1200&auto=format&fit=crop',
      },
      {
        en: 'Grilled Chicken',
        ar: 'Grilled Chicken',
        category: 'Mains',
        price: 42,
        course: 'MAIN',
        station: 'Hot Kitchen',
        imageUrl:
          'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=1200&auto=format&fit=crop',
      },
      {
        en: 'Cheesecake',
        ar: 'Cheesecake',
        category: 'Desserts',
        price: 18,
        course: 'DESSERT',
        station: 'Dessert',
        imageUrl:
          'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=1200&auto=format&fit=crop',
      },
      {
        en: 'Cola',
        ar: 'Cola',
        category: 'Drinks',
        price: 7,
        course: 'DRINK',
        station: 'Bar',
        imageUrl:
          'https://images.unsplash.com/photo-1629203432180-71e9b6d8f5c3?w=1200&auto=format&fit=crop',
      },
      {
        en: 'Orange Juice',
        ar: 'Orange Juice',
        category: 'Drinks',
        price: 9,
        course: 'DRINK',
        station: 'Bar',
        imageUrl:
          'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=1200&auto=format&fit=crop',
      },
      {
        en: 'Latte',
        ar: 'Latte',
        category: 'Drinks',
        price: 13,
        course: 'DRINK',
        station: 'Bar',
        imageUrl:
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=1200&auto=format&fit=crop',
      },
    ] as const;

    const productsByEn = new Map<string, Product>();
    for (const p of productsSeed) {
      let product = await findByEn(productsRepo, 'product', p.en);
      if (!product) product = productsRepo.create({ name: { en: p.en, ar: p.ar } });
      product.name = { en: p.en, ar: p.ar };
      product.price = p.price;
      product.imageUrl = p.imageUrl;
      product.course = p.course;
      product.isAvailable = true;
      product.category = categoriesByEn.get(p.category)!;
      product.station = stationsByName.get(p.station) ?? null;
      productsByEn.set(p.en, await productsRepo.save(product));
    }

    const tablesSeed = [
      { tableNumber: 'T1', section: 'Main Hall', capacity: 4, x: 120, y: 90 },
      { tableNumber: 'T2', section: 'Main Hall', capacity: 4, x: 280, y: 90 },
      { tableNumber: 'T3', section: 'Main Hall', capacity: 6, x: 440, y: 90 },
      { tableNumber: 'T4', section: 'Main Hall', capacity: 2, x: 600, y: 90 },
      { tableNumber: 'P1', section: 'Patio', capacity: 4, x: 120, y: 260 },
      { tableNumber: 'P2', section: 'Patio', capacity: 4, x: 280, y: 260 },
    ];

    const tablesByNo = new Map<string, Table>();
    for (const t of tablesSeed) {
      let table = await tablesRepo.findOne({ where: { tableNumber: t.tableNumber } });
      if (!table) table = tablesRepo.create({ ...t, width: 120, height: 90, shape: TableShape.RECTANGLE, rotation: 0 });
      table.section = t.section;
      table.capacity = t.capacity;
      table.x = t.x;
      table.y = t.y;
      table.width = 120;
      table.height = 90;
      table.shape = TableShape.RECTANGLE;
      table.rotation = 0;
      tablesByNo.set(t.tableNumber, await tablesRepo.save(table));
    }

    const customerSeed = [
      { name: 'Nora Ahmed', phoneNumber: '+966500000001', email: 'nora@test.local', loyaltyPoints: 250, tier: 'BRONZE' },
      { name: 'Omar Ali', phoneNumber: '+966500000002', email: 'omar@test.local', loyaltyPoints: 850, tier: 'SILVER' },
      { name: 'Laila Salem', phoneNumber: '+966500000003', email: 'laila@test.local', loyaltyPoints: 2200, tier: 'GOLD' },
      { name: 'Test Guest', phoneNumber: '+966500000004', email: 'guest@test.local', loyaltyPoints: 0, tier: 'BRONZE' },
    ];

    const customersByPhone = new Map<string, Customer>();
    for (const c of customerSeed) {
      let customer = await customersRepo.findOne({ where: { phoneNumber: c.phoneNumber } });
      if (!customer) customer = customersRepo.create(c);
      customer.name = c.name;
      customer.email = c.email;
      customer.loyaltyPoints = c.loyaltyPoints;
      customer.tier = c.tier;
      customersByPhone.set(c.phoneNumber, await customersRepo.save(customer));
    }

    const couponsSeed = [
      { code: 'WELCOME10', type: CouponType.PERCENTAGE, value: 10, minOrderAmount: 30 },
      { code: 'SAVE25', type: CouponType.FIXED_AMOUNT, value: 25, minOrderAmount: 100 },
    ];
    for (const c of couponsSeed) {
      let coupon = await couponsRepo.findOne({ where: { code: c.code } });
      if (!coupon) coupon = couponsRepo.create(c);
      coupon.type = c.type;
      coupon.value = c.value;
      coupon.minOrderAmount = c.minOrderAmount;
      coupon.isActive = true;
      coupon.maxUses = 1000;
      coupon.expiresAt = new Date('2027-12-31T23:59:59.000Z');
      await couponsRepo.save(coupon);
    }

    let mainWarehouse = await warehousesRepo.findOne({ where: { isMain: true } });
    if (!mainWarehouse) {
      mainWarehouse = await warehousesRepo.save(
        warehousesRepo.create({ name: 'Main Warehouse', isMain: true, address: 'Back Office' }),
      );
    }

    const ingredientsSeed = [
      { name: 'Chicken Breast', unit: 'kg', quantity: 60, minLevel: 15 },
      { name: 'Beef Patty', unit: 'pcs', quantity: 180, minLevel: 40 },
      { name: 'Lettuce', unit: 'kg', quantity: 30, minLevel: 8 },
      { name: 'Tomato', unit: 'kg', quantity: 35, minLevel: 10 },
      { name: 'Cheese Slice', unit: 'pcs', quantity: 320, minLevel: 80 },
      { name: 'Bread Bun', unit: 'pcs', quantity: 280, minLevel: 60 },
      { name: 'Milk', unit: 'l', quantity: 90, minLevel: 20 },
      { name: 'Coffee Beans', unit: 'kg', quantity: 24, minLevel: 6 },
      { name: 'Orange', unit: 'kg', quantity: 55, minLevel: 15 },
    ];

    const ingredientsByName = new Map<string, Ingredient>();
    for (const i of ingredientsSeed) {
      let ingredient = await ingredientsRepo.findOne({ where: { name: i.name } });
      if (!ingredient) ingredient = ingredientsRepo.create({ name: i.name, unit: i.unit });
      ingredient.unit = i.unit;
      ingredient = await ingredientsRepo.save(ingredient);
      ingredientsByName.set(i.name, ingredient);

      let item = await inventoryRepo.findOne({
        where: { ingredient: { id: ingredient.id }, warehouse: { id: mainWarehouse.id } },
        relations: ['ingredient', 'warehouse'],
      });
      if (!item) item = inventoryRepo.create({ ingredient, warehouse: mainWarehouse });
      item.quantity = i.quantity;
      item.minLevel = i.minLevel;
      await inventoryRepo.save(item);
    }

    const recipeSeed = [
      { product: 'Caesar Salad', ingredient: 'Lettuce', qty: 0.18 },
      { product: 'Caesar Salad', ingredient: 'Cheese Slice', qty: 1 },
      { product: 'Tomato Soup', ingredient: 'Tomato', qty: 0.25 },
      { product: 'Classic Burger', ingredient: 'Beef Patty', qty: 1 },
      { product: 'Classic Burger', ingredient: 'Bread Bun', qty: 1 },
      { product: 'Grilled Chicken', ingredient: 'Chicken Breast', qty: 0.32 },
      { product: 'Orange Juice', ingredient: 'Orange', qty: 0.35 },
      { product: 'Latte', ingredient: 'Milk', qty: 0.24 },
      { product: 'Latte', ingredient: 'Coffee Beans', qty: 0.018 },
    ];
    for (const r of recipeSeed) {
      await ensureRecipe(
        recipesRepo,
        ingredientsByName.get(r.ingredient)!.id,
        r.qty,
        productsByEn.get(r.product)!.id,
      );
    }

    let supplier = await suppliersRepo.findOne({ where: { name: 'Fresh Foods Co.' } });
    if (!supplier) {
      supplier = await suppliersRepo.save(
        suppliersRepo.create({
          name: 'Fresh Foods Co.',
          contactPerson: 'Procurement Team',
          phone: '+966511111111',
          email: 'orders@freshfoods.example',
          address: 'Industrial Area - Warehouse 7',
          isActive: true,
        }),
      );
    }

    const poKey = 'SEED_PO_001';
    let po = await poRepo.findOne({ where: { notes: poKey }, relations: ['items'] });
    if (!po) {
      const poItems = [
        { ingredient: 'Chicken Breast', quantity: 20, unitPrice: 28 },
        { ingredient: 'Beef Patty', quantity: 60, unitPrice: 6.5 },
      ].map((it) =>
        poItemRepo.create({
          ingredient: ingredientsByName.get(it.ingredient)!,
          ingredientId: ingredientsByName.get(it.ingredient)!.id,
          quantity: it.quantity,
          unitPrice: it.unitPrice,
          totalPrice: it.quantity * it.unitPrice,
        }),
      );
      po = await poRepo.save(
        poRepo.create({
          supplier,
          supplierId: supplier.id,
          status: PurchaseOrderStatus.ORDERED,
          totalAmount: poItems.reduce((s, i) => s + Number(i.totalPrice), 0),
          expectedDeliveryDate: '2026-02-14',
          paymentDueDate: '2026-02-28',
          notes: poKey,
          items: poItems,
        }),
      );
    }

    const seedOrders = [
      {
        key: 'SEED_ORDER_001',
        type: OrderType.DINE_IN,
        status: OrderStatus.PENDING,
        paymentMethod: PaymentMethod.LATER,
        paymentStatus: PaymentStatus.PENDING,
        table: 'T2',
        customer: '+966500000001',
        items: [{ p: 'Classic Burger', q: 1 }, { p: 'Cola', q: 1 }],
      },
      {
        key: 'SEED_ORDER_002',
        type: OrderType.DELIVERY,
        status: OrderStatus.ON_DELIVERY,
        paymentMethod: PaymentMethod.CARD,
        paymentStatus: PaymentStatus.PAID,
        customer: '+966500000003',
        driver: 'driver@pos.com',
        address: 'Olaya Street, Apartment 5A',
        deliveryFee: 10,
        items: [{ p: 'Grilled Chicken', q: 1 }, { p: 'Latte', q: 1 }],
      },
      {
        key: 'SEED_ORDER_003',
        type: OrderType.DINE_IN,
        status: OrderStatus.COMPLETED,
        paymentMethod: PaymentMethod.CASH,
        paymentStatus: PaymentStatus.PAID,
        table: 'T1',
        customer: '+966500000002',
        items: [{ p: 'Tomato Soup', q: 1 }, { p: 'Cheesecake', q: 1 }],
      },
    ];

    const createdOrders: Order[] = [];
    for (const o of seedOrders) {
      const existing = await ordersRepo.findOne({ where: { deliveryReferenceId: o.key } });
      if (existing) {
        createdOrders.push(existing);
        continue;
      }

      const items: OrderItem[] = [];
      let subtotal = 0;
      for (const rawItem of o.items) {
        const product = productsByEn.get(rawItem.p)!;
        subtotal += Number(product.price) * rawItem.q;
        items.push(
          orderItemsRepo.create({
            product,
            quantity: rawItem.q,
            price: product.price,
            status: o.status === OrderStatus.COMPLETED ? 'SERVED' : 'PENDING',
            modifiers: [],
            taxAmount: 0,
            discountAmount: 0,
          }),
        );
      }

      const orderToSave: Partial<Order> = {
        type: o.type,
        table: o.table ? tablesByNo.get(o.table)! : null,
        status: o.status,
        paymentMethod: o.paymentMethod,
        paymentStatus: o.paymentStatus,
        items,
        totalAmount: subtotal + (o.deliveryFee ?? 0),
        taxAmount: 0,
        discountAmount: 0,
        customerId: customersByPhone.get(o.customer)?.id ?? undefined,
        driverId: o.driver ? usersByEmail.get(o.driver)?.id ?? undefined : undefined,
        deliveryAddress: o.address ?? undefined,
        deliveryFee: o.deliveryFee ?? 0,
        deliveryProvider: o.type === OrderType.DELIVERY ? 'internal' : undefined,
        deliveryReferenceId: o.key,
      };

      const saved = await ordersRepo.save(orderToSave as Order);
      createdOrders.push(saved);
    }

    for (const [no, table] of tablesByNo.entries()) {
      table.status = no === 'T2' ? TableStatus.OCCUPIED : TableStatus.FREE;
      await tablesRepo.save(table);
    }

    const completedOrder = createdOrders.find((o) => o.deliveryReferenceId === 'SEED_ORDER_003');
    const manager = usersByEmail.get('manager@pos.com');
    if (completedOrder && manager) {
      const existingRefund = await refundsRepo.findOne({ where: { order: { id: completedOrder.id }, reason: 'SEED_REFUND_REQUEST' }, relations: ['order'] });
      if (!existingRefund) {
        await refundsRepo.save(
          refundsRepo.create({
            order: completedOrder,
            amount: 8,
            reason: 'SEED_REFUND_REQUEST',
            managerId: manager.id,
            status: 'PENDING',
          }),
        );
      }
    }

    const cashier = usersByEmail.get('cashier@pos.com');
    if (cashier) {
      let shift = await shiftsRepo.findOne({ where: { deviceId: 'SEED_SHIFT_OPEN_01', user: { id: cashier.id } }, relations: ['user'] });
      if (!shift) {
        shift = await shiftsRepo.save(
          shiftsRepo.create({
            user: cashier,
            deviceId: 'SEED_SHIFT_OPEN_01',
            startTime: new Date(),
            startingCash: 400,
            status: ShiftStatus.OPEN,
          }),
        );
      }

      const tx = await cashTxRepo.findOne({ where: { shift: { id: shift.id }, reason: 'Seed cash-in' }, relations: ['shift'] });
      if (!tx) {
        await cashTxRepo.save(
          cashTxRepo.create({
            shift,
            type: TransactionType.IN,
            amount: 60,
            reason: 'Seed cash-in',
          }),
        );
      }
    }

    console.log('Seed finished successfully.');
    console.log('Sample table links for customer menu:');
    for (const [tableNo, table] of tablesByNo.entries()) {
      console.log(`Table ${tableNo}: http://localhost:8081/?t=${table.qrCode}`);
    }
    console.log('Credentials:');
    console.log('admin@pos.com / admin123');
    console.log('manager@pos.com / manager123');
    console.log('cashier@pos.com / cashier123');
    console.log('waiter@pos.com / waiter123');
    console.log('kitchen@pos.com / kitchen123');
    console.log('driver@pos.com / driver123');
  } finally {
    await app.close();
  }
}

bootstrap();
