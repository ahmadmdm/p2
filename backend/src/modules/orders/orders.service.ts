import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource, EntityManager } from 'typeorm';
import {
  Order,
  OrderSource,
  OrderStatus,
  PaymentMethod,
  PaymentStatus,
  OrderType,
} from './order.entity';
import { OrderItem } from './order-item.entity';
import { Refund } from './refund.entity';
import { Table, TableStatus } from '../tables/table.entity';
import { Product } from '../catalog/product.entity';
import { Customer } from '../customers/customer.entity';
import { InventoryService } from '../inventory/inventory.service';
import { OrdersGateway } from './orders.gateway';
import { CustomersService } from '../customers/customers.service';
import { CouponsService } from '../customers/coupons.service';
import { CouponType } from '../customers/coupon.entity';
import { ShiftsService } from '../shifts/shifts.service';
import { LoyaltyTransactionType } from '../customers/loyalty-transaction.entity';
import {
  canTransitionOrderItemStatus,
  canTransitionOrderStatus,
  isFinalOrderStatus,
  isOrderItemStatus,
} from './order-status.workflow';

@Injectable()
export class OrdersService {
  constructor(
    @InjectRepository(Order)
    private ordersRepository: Repository<Order>,
    @InjectRepository(OrderItem)
    private orderItemsRepository: Repository<OrderItem>,
    @InjectRepository(Product)
    private productsRepository: Repository<Product>,
    @InjectRepository(Table)
    private tablesRepository: Repository<Table>,
    @InjectRepository(Refund)
    private refundsRepository: Repository<Refund>,
    private inventoryService: InventoryService,
    private ordersGateway: OrdersGateway,
    private customersService: CustomersService,
    private couponsService: CouponsService,
    private shiftsService: ShiftsService,
    private dataSource: DataSource,
  ) {}

  private ensureOrderStatusTransition(
    from: OrderStatus,
    to: OrderStatus,
    context: string,
  ) {
    if (!canTransitionOrderStatus(from, to)) {
      throw new BadRequestException(
        `Invalid order status transition in ${context}: ${from} -> ${to}`,
      );
    }
  }

  private isUuid(value: string): boolean {
    return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(
      value,
    );
  }

  private parsePositiveInteger(value: unknown, fieldName: string): number {
    const parsed = Number(value);
    if (!Number.isInteger(parsed) || parsed <= 0) {
      throw new BadRequestException(`${fieldName} must be a positive integer`);
    }
    return parsed;
  }

  private parseNonNegativeAmount(value: unknown, fieldName: string): number {
    const parsed = Number(value ?? 0);
    if (Number.isNaN(parsed) || parsed < 0) {
      throw new BadRequestException(
        `${fieldName} must be a non-negative number`,
      );
    }
    return parsed;
  }

  private normalizeRequestedModifierIds(rawModifiers: unknown): string[] {
    if (!Array.isArray(rawModifiers)) {
      return [];
    }

    const ids = rawModifiers
      .map((modifier) => {
        if (typeof modifier === 'string') {
          return modifier.trim();
        }
        if (
          modifier &&
          typeof modifier === 'object' &&
          typeof (modifier as { id?: unknown }).id === 'string'
        ) {
          return ((modifier as { id: string }).id || '').trim();
        }
        return '';
      })
      .filter((id): id is string => Boolean(id));

    return [...new Set(ids)];
  }

  private normalizeOrderItemStatus(rawStatus: unknown): string {
    if (rawStatus === undefined || rawStatus === null || rawStatus === '') {
      return OrderStatus.PENDING;
    }
    if (typeof rawStatus !== 'string' || !isOrderItemStatus(rawStatus)) {
      throw new BadRequestException(`Invalid order item status: ${rawStatus}`);
    }
    return rawStatus;
  }

  private async buildValidatedModifiers(
    product: Product,
    requestedModifierIds: string[],
  ): Promise<{
    modifiers: any[];
    modifiersTotal: number;
    modifierIds: string[];
  }> {
    const groups = product.modifierGroups || [];
    if (groups.length === 0) {
      if (requestedModifierIds.length > 0) {
        throw new BadRequestException(
          `Product ${product.name.en} does not support modifiers`,
        );
      }
      return { modifiers: [], modifiersTotal: 0, modifierIds: [] };
    }

    const itemToGroup = new Map<string, string>();
    const itemSnapshots = new Map<
      string,
      { id: string; name: any; price: number }
    >();

    for (const group of groups) {
      for (const item of group.items || []) {
        itemToGroup.set(item.id, group.id);
        itemSnapshots.set(item.id, {
          id: item.id,
          name: item.name,
          price: Number(item.price),
        });
      }
    }

    for (const requestedId of requestedModifierIds) {
      if (!itemToGroup.has(requestedId)) {
        throw new BadRequestException(
          `Modifier ${requestedId} is not valid for product ${product.name.en}`,
        );
      }
    }

    const selectedPerGroup = new Map<string, string[]>();
    for (const modifierId of requestedModifierIds) {
      const groupId = itemToGroup.get(modifierId)!;
      const current = selectedPerGroup.get(groupId) || [];
      current.push(modifierId);
      selectedPerGroup.set(groupId, current);
    }

    for (const group of groups) {
      const selectedCount = (selectedPerGroup.get(group.id) || []).length;
      const min = Number(group.minSelection || 0);
      const max = Number(group.maxSelection || 0);

      if (selectedCount < min) {
        throw new BadRequestException(
          `At least ${min} modifier(s) are required for ${group.name.en || group.id}`,
        );
      }
      if (max > 0 && selectedCount > max) {
        throw new BadRequestException(
          `Only ${max} modifier(s) allowed for ${group.name.en || group.id}`,
        );
      }
    }

    const modifiers = requestedModifierIds.map((modifierId) => {
      const snapshot = itemSnapshots.get(modifierId)!;
      return {
        id: snapshot.id,
        name: snapshot.name,
        price: snapshot.price,
      };
    });

    const modifiersTotal = modifiers.reduce(
      (sum, modifier) => sum + Number(modifier.price),
      0,
    );

    return {
      modifiers,
      modifiersTotal,
      modifierIds: requestedModifierIds,
    };
  }

  private async prepareOrderItems(items: any[]): Promise<{
    orderItems: OrderItem[];
    stockCheckItems: {
      productId: string;
      quantity: number;
      modifierIds: string[];
    }[];
    subtotal: number;
    tax: number;
    discount: number;
  }> {
    const orderItems: OrderItem[] = [];
    const stockCheckItems: {
      productId: string;
      quantity: number;
      modifierIds: string[];
    }[] = [];
    let subtotal = 0;
    let tax = 0;
    let discount = 0;

    for (const item of items) {
      if (!item.productId || typeof item.productId !== 'string') {
        throw new BadRequestException('Product ID is required');
      }

      const product = await this.productsRepository.findOne({
        where: { id: item.productId },
        relations: ['modifierGroups', 'modifierGroups.items'],
      });
      if (!product) {
        throw new NotFoundException(`Product ${item.productId} not found`);
      }
      if (!product.isAvailable) {
        throw new BadRequestException(
          `Product ${product.name.en} is unavailable`,
        );
      }

      const quantity = this.parsePositiveInteger(item.quantity, 'Quantity');
      const itemTax = this.parseNonNegativeAmount(item.taxAmount, 'Tax amount');
      const itemDiscount = this.parseNonNegativeAmount(
        item.discountAmount,
        'Discount amount',
      );
      const requestedModifierIds = this.normalizeRequestedModifierIds(
        item.modifiers,
      );
      const validatedModifiers = await this.buildValidatedModifiers(
        product,
        requestedModifierIds,
      );

      const orderItem = new OrderItem();
      orderItem.product = product;
      orderItem.quantity = quantity;
      orderItem.notes = typeof item.notes === 'string' ? item.notes : undefined;
      orderItem.status = this.normalizeOrderItemStatus(item.status);
      orderItem.modifiers = validatedModifiers.modifiers;
      orderItem.price =
        Number(product.price) + validatedModifiers.modifiersTotal;
      orderItem.taxAmount = itemTax;
      orderItem.discountAmount = itemDiscount;

      const lineItemGross = Number(orderItem.price) * quantity;
      subtotal += lineItemGross;
      tax += itemTax;
      discount += itemDiscount;

      stockCheckItems.push({
        productId: product.id,
        quantity,
        modifierIds: validatedModifiers.modifierIds,
      });
      orderItems.push(orderItem);
    }

    return { orderItems, stockCheckItems, subtotal, tax, discount };
  }

  private async releaseTableIfOccupied(
    order: Order,
    manager?: EntityManager,
  ): Promise<void> {
    if (order.table && order.table.status === TableStatus.OCCUPIED) {
      order.table.status = TableStatus.FREE;
      if (manager) {
        await manager.save(Table, order.table);
      } else {
        await this.tablesRepository.save(order.table);
      }
    }
  }

  async createOrder(data: any, userId?: string): Promise<Order> {
    const {
      items,
      tableId,
      type,
      source,
      paymentMethod,
      customerId,
      deliveryAddress,
      driverId,
      deliveryFee,
    } = data;

    if (!Array.isArray(items) || items.length === 0) {
      throw new BadRequestException('Order must contain at least one item');
    }

    let table: Table | null = null;
    const normalizedTableId = typeof tableId === 'string' ? tableId.trim() : '';
    if (normalizedTableId) {
      if (this.isUuid(normalizedTableId)) {
        table = await this.tablesRepository.findOneBy({
          id: normalizedTableId,
        });
      } else {
        table = await this.tablesRepository.findOne({
          where: { tableNumber: normalizedTableId },
        });
      }
      if (!table) {
        throw new NotFoundException('Table not found');
      }
    }

    const effectiveType = (type ||
      (table ? OrderType.DINE_IN : OrderType.TAKEAWAY)) as OrderType;
    if (!Object.values(OrderType).includes(effectiveType)) {
      throw new BadRequestException(`Invalid order type: ${type}`);
    }
    if (effectiveType === OrderType.DINE_IN && !table) {
      throw new BadRequestException('Table ID is required for Dine-in orders');
    }

    const effectivePaymentMethod = (paymentMethod ||
      PaymentMethod.LATER) as PaymentMethod;
    if (!Object.values(PaymentMethod).includes(effectivePaymentMethod)) {
      throw new BadRequestException(`Invalid payment method: ${paymentMethod}`);
    }

    const effectiveSource = (source || OrderSource.POS) as OrderSource;
    if (!Object.values(OrderSource).includes(effectiveSource)) {
      throw new BadRequestException(`Invalid order source: ${source}`);
    }

    const preparedItems = await this.prepareOrderItems(items);
    const hasStock = await this.inventoryService.checkStockAvailability(
      preparedItems.stockCheckItems,
    );
    if (!hasStock) {
      throw new BadRequestException('Insufficient stock for one or more items');
    }

    return this.dataSource.transaction(async (manager) => {
      const globalTax = this.parseNonNegativeAmount(
        data.taxAmount,
        'Tax amount',
      );
      const globalDiscount = this.parseNonNegativeAmount(
        data.discountAmount,
        'Discount amount',
      );
      const normalizedDeliveryFee = this.parseNonNegativeAmount(
        deliveryFee,
        'Delivery fee',
      );

      const totalTax = preparedItems.tax + globalTax;
      const totalDiscount = preparedItems.discount + globalDiscount;
      const finalTotal =
        preparedItems.subtotal -
        totalDiscount +
        totalTax +
        normalizedDeliveryFee;

      const order = new Order();
      order.table = table;
      order.type = effectiveType;
      order.source = effectiveSource;
      order.deliveryAddress = deliveryAddress;
      order.deliveryFee = normalizedDeliveryFee;
      order.driverId = driverId;
      order.items = preparedItems.orderItems;
      order.taxAmount = totalTax;
      order.discountAmount = totalDiscount;
      order.totalAmount = finalTotal;
      order.status = OrderStatus.PENDING;
      order.paymentMethod = effectivePaymentMethod;

      if (table && table.status === TableStatus.FREE) {
        table.status = TableStatus.OCCUPIED;
        await manager.save(table);
      }

      const savedOrder = await manager.save(order);

      if (
        effectivePaymentMethod === PaymentMethod.CASH ||
        effectivePaymentMethod === PaymentMethod.CARD
      ) {
        savedOrder.paymentStatus = PaymentStatus.PAID;
      } else if (effectivePaymentMethod === PaymentMethod.LOYALTY) {
        if (!customerId) {
          throw new BadRequestException(
            'Customer required for loyalty payment',
          );
        }
        const pointsNeeded = Math.ceil(finalTotal * 10);

        const customer = await manager.findOne(Customer, {
          where: { id: customerId },
        });
        if (!customer) {
          throw new NotFoundException('Customer not found');
        }

        if (customer.loyaltyPoints < pointsNeeded) {
          throw new BadRequestException(
            `Insufficient loyalty points. Needed: ${pointsNeeded}, Available: ${customer.loyaltyPoints}`,
          );
        }

        await this.customersService.addPoints(
          customerId,
          -pointsNeeded,
          LoyaltyTransactionType.REDEEM,
          savedOrder.id,
          manager,
        );

        savedOrder.paymentStatus = PaymentStatus.PAID;
      }

      if (customerId) {
        savedOrder.customerId = customerId;
      }

      if (userId) {
        const shift = await this.shiftsService.getOpenShift(userId);
        if (shift) {
          savedOrder.shiftId = shift.id;
        }
      }

      await manager.save(Order, savedOrder);
      await this.inventoryService.deductStockForOrder(
        preparedItems.stockCheckItems,
        manager,
      );

      this.ordersGateway.notifyNewOrder(savedOrder);
      return savedOrder;
    });
  }

  async addItemsToOrder(orderId: string, items: any[]): Promise<Order> {
    const order = await this.ordersRepository.findOne({
      where: { id: orderId },
      relations: ['items', 'table', 'customer'],
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (isFinalOrderStatus(order.status)) {
      throw new BadRequestException('Cannot add items to a closed order');
    }

    if (!Array.isArray(items) || items.length === 0) {
      throw new BadRequestException('Items are required');
    }

    const preparedItems = await this.prepareOrderItems(items);
    const hasStock = await this.inventoryService.checkStockAvailability(
      preparedItems.stockCheckItems,
    );
    if (!hasStock) {
      throw new BadRequestException('Insufficient stock for one or more items');
    }

    return this.dataSource.transaction(async (manager) => {
      const newOrderItems: OrderItem[] = [];
      for (const orderItem of preparedItems.orderItems) {
        orderItem.status = OrderStatus.PENDING;
        orderItem.order = order;
        const savedItem = await manager.save(OrderItem, orderItem);
        newOrderItems.push(savedItem);
      }

      order.taxAmount = Number(order.taxAmount) + preparedItems.tax;
      order.discountAmount =
        Number(order.discountAmount) + preparedItems.discount;
      order.totalAmount =
        Number(order.totalAmount) +
        (preparedItems.subtotal - preparedItems.discount + preparedItems.tax);

      if (!order.items) {
        order.items = [];
      }
      order.items.push(...newOrderItems);

      const savedOrder = await manager.save(Order, order);

      await this.inventoryService.deductStockForOrder(
        preparedItems.stockCheckItems,
        manager,
      );

      this.ordersGateway.notifyOrderUpdate(savedOrder);

      return savedOrder;
    });
  }

  notifyBillRequest(table: Table) {
    this.ordersGateway.notifyBillRequested(table);
  }

  async findAll(): Promise<Order[]> {
    return this.ordersRepository.find({
      relations: [
        'items',
        'items.product',
        'items.product.station',
        'table',
        'refunds',
      ],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<Order> {
    const order = await this.ordersRepository.findOne({
      where: { id },
      relations: [
        'items',
        'items.product',
        'items.product.station',
        'table',
        'refunds',
      ],
    });

    if (!order) {
      throw new NotFoundException(`Order ${id} not found`);
    }
    return order;
  }

  async rejectRefund(refundId: string, managerId: string): Promise<Refund> {
    const refund = await this.refundsRepository.findOne({
      where: { id: refundId },
      relations: ['order'],
    });

    if (!refund) {
      throw new NotFoundException(`Refund ${refundId} not found`);
    }

    if (refund.status !== 'PENDING') {
      throw new BadRequestException('Refund already processed');
    }

    refund.managerId = managerId;
    refund.status = 'REJECTED';
    refund.approvedAt = new Date();
    return this.refundsRepository.save(refund);
  }

  async findPendingRefunds(): Promise<Refund[]> {
    return this.refundsRepository.find({
      where: { status: 'PENDING' },
      relations: ['order', 'order.items', 'order.items.product'],
      order: { createdAt: 'ASC' },
    });
  }

  async voidOrder(
    orderId: string,
    managerId: string,
    reason: string,
    returnStock: boolean = false,
  ): Promise<Order> {
    return this.dataSource.transaction(async (manager) => {
      const order = await manager.findOne(Order, {
        where: { id: orderId },
        relations: ['items', 'items.product'],
      });

      if (!order) {
        throw new NotFoundException(`Order ${orderId} not found`);
      }

      if (!reason?.trim()) {
        throw new BadRequestException('Void reason is required');
      }

      if (
        order.status === OrderStatus.CANCELLED ||
        order.status === OrderStatus.COMPLETED ||
        order.status === OrderStatus.REFUNDED ||
        order.status === OrderStatus.VOIDED
      ) {
        throw new BadRequestException(
          'Cannot void a completed, cancelled, refunded, or already voided order',
        );
      }

      this.ensureOrderStatusTransition(
        order.status,
        OrderStatus.VOIDED,
        'void',
      );
      order.status = OrderStatus.VOIDED;

      if (returnStock) {
        const stockItems = order.items.map((item) => ({
          productId: item.product.id,
          quantity: item.quantity,
          modifierIds: item.modifiers ? item.modifiers.map((m) => m.id) : [],
        }));
        await this.inventoryService.restoreStockForOrder(stockItems, manager);
      }

      await this.releaseTableIfOccupied(order, manager);
      const savedOrder = await manager.save(order);
      this.ordersGateway.notifyOrderUpdate(savedOrder);
      return savedOrder;
    });
  }

  async updateStatus(id: string, status: OrderStatus): Promise<Order> {
    const order = await this.findOne(id);
    this.ensureOrderStatusTransition(order.status, status, 'updateStatus');
    order.status = status;
    if (isFinalOrderStatus(status)) {
      await this.releaseTableIfOccupied(order);
    }
    const saved = await this.ordersRepository.save(order);
    this.ordersGateway.notifyOrderUpdate(saved);
    return saved;
  }

  async applyCoupon(id: string, code: string): Promise<Order> {
    const order = await this.findOne(id);

    if (isFinalOrderStatus(order.status)) {
      throw new BadRequestException('Cannot apply coupon to closed order');
    }

    if (order.couponCode) {
      throw new BadRequestException('Order already has a coupon applied');
    }

    const coupon = await this.couponsService.validateCoupon(
      code,
      Number(order.totalAmount),
    );

    let discount = 0;
    if (coupon.type === CouponType.PERCENTAGE) {
      discount = Number(order.totalAmount) * (Number(coupon.value) / 100);
    } else {
      discount = Number(coupon.value);
    }

    // Ensure discount doesn't exceed total
    if (discount > Number(order.totalAmount)) {
      discount = Number(order.totalAmount);
    }

    order.discountAmount = Number(order.discountAmount) + discount;
    order.totalAmount = Number(order.totalAmount) - discount;
    order.couponCode = code;

    const saved = await this.ordersRepository.save(order);
    await this.couponsService.incrementUsage(coupon.id);

    this.ordersGateway.notifyOrderUpdate(saved);
    return saved;
  }

  async redeemPoints(id: string, points: number): Promise<Order> {
    const order = await this.findOne(id);
    if (!order.customerId)
      throw new BadRequestException('Order has no customer attached');
    if (isFinalOrderStatus(order.status)) {
      throw new BadRequestException('Cannot redeem points on closed order');
    }

    const customer = await this.customersService.findOne(order.customerId);
    if (!customer) throw new NotFoundException('Customer not found');
    if (customer.loyaltyPoints < points)
      throw new BadRequestException('Insufficient points');

    // Calculate value: 10 points = 1.00 currency
    const discountValue = points / 10;

    if (discountValue > Number(order.totalAmount)) {
      throw new BadRequestException('Redemption value exceeds order total');
    }

    // Deduct points immediately
    await this.customersService.addPoints(
      order.customerId,
      -points,
      LoyaltyTransactionType.REDEEM,
      id,
    );

    order.discountAmount = Number(order.discountAmount) + discountValue;
    order.totalAmount = Number(order.totalAmount) - discountValue;
    order.redeemedPoints = (Number(order.redeemedPoints) || 0) + points;

    const saved = await this.ordersRepository.save(order);
    this.ordersGateway.notifyOrderUpdate(saved);
    return saved;
  }

  async payOrder(id: string, paymentMethod: PaymentMethod): Promise<Order> {
    const order = await this.findOne(id);
    if (isFinalOrderStatus(order.status)) {
      throw new BadRequestException('Order is already closed');
    }
    this.ensureOrderStatusTransition(
      order.status,
      OrderStatus.COMPLETED,
      'pay',
    );
    order.paymentMethod = paymentMethod;
    order.paymentStatus = PaymentStatus.PAID;
    order.status = OrderStatus.COMPLETED;

    await this.releaseTableIfOccupied(order);

    // Award loyalty points (10 points per 1.00 spent)
    if (order.customerId) {
      const pointsEarned = Math.floor(Number(order.totalAmount) * 10);
      if (pointsEarned > 0) {
        await this.customersService.addPoints(
          order.customerId,
          pointsEarned,
          LoyaltyTransactionType.EARN,
          order.id,
        );
      }
    }

    const saved = await this.ordersRepository.save(order);
    this.ordersGateway.notifyOrderUpdate(saved);
    return saved;
  }

  async fireCourse(id: string, course: string): Promise<Order> {
    const order = await this.findOne(id);
    if (isFinalOrderStatus(order.status)) {
      throw new BadRequestException('Cannot fire courses for a closed order');
    }
    // Find items belonging to this course that are PENDING
    const itemsToFire = order.items.filter(
      (item) => item.status === 'PENDING' && item.product.course === course,
    );

    if (itemsToFire.length > 0) {
      for (const item of itemsToFire) {
        item.status = 'PREPARING';
        await this.orderItemsRepository.save(item);
      }

      // Reload to get updated items
      const saved = await this.findOne(id);
      this.ordersGateway.notifyOrderUpdate(saved);
      return saved;
    }
    return order;
  }

  async assignDriver(id: string, driverId: string): Promise<Order> {
    const order = await this.findOne(id);
    if (order.type !== OrderType.DELIVERY) {
      throw new BadRequestException(
        'Driver can only be assigned to delivery orders',
      );
    }
    if (!driverId?.trim()) {
      throw new BadRequestException('Driver ID is required');
    }
    this.ensureOrderStatusTransition(
      order.status,
      OrderStatus.ON_DELIVERY,
      'assignDriver',
    );
    order.driverId = driverId;
    order.status = OrderStatus.ON_DELIVERY;
    const saved = await this.ordersRepository.save(order);
    this.ordersGateway.notifyOrderUpdate(saved);
    return saved;
  }

  async findByDriver(driverId: string): Promise<Order[]> {
    return this.ordersRepository.find({
      where: { driverId },
      relations: ['items', 'table', 'customer'],
      order: { createdAt: 'DESC' },
    });
  }

  async findActiveOrderForTable(tableId: string): Promise<Order | null> {
    return this.ordersRepository
      .createQueryBuilder('order')
      .leftJoinAndSelect('order.items', 'items')
      .leftJoinAndSelect('items.product', 'product')
      .where('order.tableId = :tableId', { tableId })
      .andWhere('order.status NOT IN (:...statuses)', {
        statuses: [
          OrderStatus.COMPLETED,
          OrderStatus.CANCELLED,
          OrderStatus.VOIDED,
          OrderStatus.REFUNDED,
        ],
      })
      .orderBy('order.createdAt', 'DESC')
      .getOne();
  }

  async findActiveOrders(): Promise<Order[]> {
    return this.ordersRepository
      .createQueryBuilder('order')
      .leftJoinAndSelect('order.items', 'items')
      .leftJoinAndSelect('items.product', 'product')
      .leftJoinAndSelect('product.station', 'station')
      .leftJoinAndSelect('order.table', 'table')
      .where('order.status NOT IN (:...statuses)', {
        statuses: [
          OrderStatus.COMPLETED,
          OrderStatus.CANCELLED,
          OrderStatus.VOIDED,
          OrderStatus.REFUNDED,
        ],
      })
      .orderBy('order.createdAt', 'DESC')
      .getMany();
  }

  async updateOrderItemStatus(
    itemId: string,
    status: string,
  ): Promise<OrderItem> {
    const item = await this.orderItemsRepository.findOne({
      where: { id: itemId },
      relations: ['order'],
    });
    if (!item) throw new NotFoundException('Item not found');

    if (!isOrderItemStatus(status)) {
      throw new BadRequestException(`Invalid order item status: ${status}`);
    }

    const currentStatus = item.status;
    if (!isOrderItemStatus(currentStatus)) {
      throw new BadRequestException(
        `Unexpected current item status: ${currentStatus}`,
      );
    }

    if (!canTransitionOrderItemStatus(currentStatus, status)) {
      throw new BadRequestException(
        `Invalid order item status transition: ${currentStatus} -> ${status}`,
      );
    }

    item.status = status;
    const saved = await this.orderItemsRepository.save(item);

    const order = await this.findOne(item.order.id);
    this.ordersGateway.notifyOrderUpdate(order);

    return saved;
  }

  async updateDeliveryInfo(id: string, info: any): Promise<Order> {
    const order = await this.findOne(id);
    if (info.driverId) order.driverId = info.driverId;
    return this.ordersRepository.save(order);
  }

  async findByDeliveryReferenceId(refId: string): Promise<Order | null> {
    const normalizedRefId = refId?.trim();
    if (!normalizedRefId) {
      return null;
    }
    return this.ordersRepository.findOne({
      where: { deliveryReferenceId: normalizedRefId },
      relations: ['items', 'items.product', 'table', 'refunds'],
    });
  }

  async requestRefund(
    orderId: string,
    amount: number,
    reason: string,
  ): Promise<Refund> {
    const order = await this.findOne(orderId);
    if (amount <= 0 || amount > Number(order.totalAmount)) {
      throw new BadRequestException('Refund amount must be within order total');
    }
    if (!reason?.trim()) {
      throw new BadRequestException('Refund reason is required');
    }
    if (order.paymentStatus !== PaymentStatus.PAID) {
      throw new BadRequestException('Refund requires a paid order');
    }
    if (
      order.status !== OrderStatus.COMPLETED &&
      order.status !== OrderStatus.DELIVERED &&
      order.status !== OrderStatus.SERVED
    ) {
      throw new BadRequestException(
        'Refund can only be requested for served, delivered, or completed orders',
      );
    }

    const pendingRefund = await this.refundsRepository.findOne({
      where: { order: { id: orderId }, status: 'PENDING' },
      relations: ['order'],
    });
    if (pendingRefund) {
      throw new BadRequestException(
        'Order already has a pending refund request',
      );
    }

    const refund = this.refundsRepository.create({
      order,
      amount,
      reason,
      status: 'PENDING',
    });
    return this.refundsRepository.save(refund);
  }

  async approveRefund(refundId: string, managerId: string): Promise<Refund> {
    return this.dataSource.transaction(async (manager) => {
      const refund = await manager.findOne(Refund, {
        where: { id: refundId },
        relations: ['order', 'order.table'],
      });
      if (!refund) {
        throw new NotFoundException('Refund not found');
      }
      if (refund.status !== 'PENDING') {
        throw new BadRequestException('Refund already processed');
      }

      this.ensureOrderStatusTransition(
        refund.order.status,
        OrderStatus.REFUNDED,
        'approveRefund',
      );

      refund.status = 'APPROVED';
      refund.managerId = managerId;
      refund.approvedAt = new Date();
      refund.order.status = OrderStatus.REFUNDED;

      const savedRefund = await manager.save(Refund, refund);
      await manager.save(Order, refund.order);
      await this.releaseTableIfOccupied(refund.order, manager);
      this.ordersGateway.notifyOrderUpdate(refund.order);
      return savedRefund;
    });
  }
}
