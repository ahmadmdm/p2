import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource, EntityManager } from 'typeorm';
import {
  Order,
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
      paymentMethod,
      customerId,
      deliveryAddress,
      driverId,
      deliveryFee,
    } = data;

    if (!items || items.length === 0) {
      throw new BadRequestException('Order must contain at least one item');
    }

    // Validate Table for Dine-in
    let table: Table | null = null;
    const normalizedTableId =
      typeof tableId === 'string' ? tableId.trim() : undefined;
    if (normalizedTableId) {
      if (this.isUuid(normalizedTableId)) {
        table = await this.tablesRepository.findOneBy({ id: normalizedTableId });
      } else {
        table = await this.tablesRepository.findOne({
          where: { tableNumber: normalizedTableId },
        });
      }
      if (!table) {
        throw new NotFoundException('Table not found');
      }
    }

    const effectiveType = type || (table ? OrderType.DINE_IN : OrderType.TAKEAWAY);

    if (effectiveType === OrderType.DINE_IN && !table) {
      throw new BadRequestException('Table ID is required for Dine-in orders');
    }

    // Check Stock Availability
    const stockCheckItems = items.map((item: any) => ({
      productId: item.productId,
      quantity: item.quantity,
      modifierIds: item.modifiers ? item.modifiers.map((m: any) => m.id) : [],
    }));

    const hasStock =
      await this.inventoryService.checkStockAvailability(stockCheckItems);
    if (!hasStock) {
      throw new BadRequestException('Insufficient stock for one or more items');
    }

    // Use Transaction
    return this.dataSource.transaction(async (manager) => {
      // Process Items
      const orderItems: OrderItem[] = [];
      let subtotal = 0;
      let totalTax = 0;
      let totalDiscount = 0;

      for (const item of items) {
        if (!item.productId) {
          throw new BadRequestException('Product ID is required');
        }
        const product = await this.productsRepository.findOneBy({
          id: item.productId,
        });
        if (!product) {
          throw new NotFoundException(`Product ${item.productId} not found`);
        }
        if (!product.isAvailable) {
          throw new BadRequestException(
            `Product ${product.name.en} is unavailable`,
          );
        }

        const orderItem = new OrderItem();
        orderItem.product = product;
        orderItem.quantity = item.quantity;
        orderItem.notes = item.notes;
        orderItem.status = item.status || OrderStatus.PENDING;
        orderItem.modifiers = item.modifiers || [];

        let itemUnitPrice = Number(product.price);
        if (item.modifiers && Array.isArray(item.modifiers)) {
          for (const mod of item.modifiers) {
            itemUnitPrice += Number(mod.price || 0);
          }
        }
        orderItem.price = itemUnitPrice;

        // Handle Item Tax & Discount
        const itemTax = Number(item.taxAmount || 0);
        const itemDiscount = Number(item.discountAmount || 0);

        orderItem.taxAmount = itemTax;
        orderItem.discountAmount = itemDiscount;

        const lineItemGross = itemUnitPrice * item.quantity;
        subtotal += lineItemGross;
        totalTax += itemTax;
        totalDiscount += itemDiscount;

        orderItems.push(orderItem);
      }

      // Handle Global Order Tax & Discount
      const globalTax = Number(data.taxAmount || 0);
      const globalDiscount = Number(data.discountAmount || 0);

      totalTax += globalTax;
      totalDiscount += globalDiscount;

      const finalTotal =
        subtotal - totalDiscount + totalTax + (deliveryFee || 0);

      // Create Order
      const order = new Order();
      order.table = table;
      order.type = effectiveType;
      order.deliveryAddress = deliveryAddress;
      order.deliveryFee = deliveryFee || 0;
      order.driverId = driverId;
      order.items = orderItems;
      order.taxAmount = totalTax;
      order.discountAmount = totalDiscount;
      order.totalAmount = finalTotal;
      order.status = OrderStatus.PENDING;
      order.paymentMethod = paymentMethod || PaymentMethod.LATER;

      // Update Table Status if needed
      if (table && table.status === TableStatus.FREE) {
        table.status = TableStatus.OCCUPIED;
        await manager.save(table);
      }

      // Save initially to get ID for loyalty transaction
      const savedOrder = await manager.save(order);

      if (
        paymentMethod === PaymentMethod.CASH ||
        paymentMethod === PaymentMethod.CARD
      ) {
        savedOrder.paymentStatus = PaymentStatus.PAID;
      } else if (paymentMethod === PaymentMethod.LOYALTY) {
        if (!customerId) {
          throw new BadRequestException(
            'Customer required for loyalty payment',
          );
        }
        // Check points logic
        // 10 points = 1.00 currency
        // Points needed = totalAmount * 10
        const pointsNeeded = Math.ceil(finalTotal * 10);

        // We need to check if customer has enough points
        // Since we are inside a transaction, we should use the manager to find the customer to lock it?
        // For now simple check
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

        // Deduct Points
        // We use CustomersService.addPoints with negative value
        // Ensure addPoints supports negative
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

      // Deduct Stock
      await this.inventoryService.deductStockForOrder(stockCheckItems, manager);

      // Notify KDS
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

    // Check Stock Availability
    const stockCheckItems = items.map((item: any) => ({
      productId: item.productId,
      quantity: item.quantity,
      modifierIds: item.modifiers ? item.modifiers.map((m: any) => m.id) : [],
    }));

    const hasStock =
      await this.inventoryService.checkStockAvailability(stockCheckItems);
    if (!hasStock) {
      throw new BadRequestException('Insufficient stock for one or more items');
    }

    return this.dataSource.transaction(async (manager) => {
      // Process New Items
      const newOrderItems: OrderItem[] = [];
      let additionalSubtotal = 0;
      let additionalTax = 0;
      let additionalDiscount = 0;

      for (const item of items) {
        if (!item.productId) {
          throw new BadRequestException('Product ID is required');
        }
        const product = await this.productsRepository.findOneBy({
          id: item.productId,
        });
        if (!product) {
          throw new NotFoundException(`Product ${item.productId} not found`);
        }
        if (!product.isAvailable) {
          throw new BadRequestException(
            `Product ${product.name.en} is unavailable`,
          );
        }

        const orderItem = new OrderItem();
        orderItem.product = product;
        orderItem.quantity = item.quantity;
        orderItem.notes = item.notes;
        orderItem.status = OrderStatus.PENDING;
        orderItem.modifiers = item.modifiers || [];
        orderItem.order = order; // Link to order

        let itemUnitPrice = Number(product.price);
        if (item.modifiers && Array.isArray(item.modifiers)) {
          for (const mod of item.modifiers) {
            itemUnitPrice += Number(mod.price || 0);
          }
        }
        orderItem.price = itemUnitPrice;

        const itemTax = Number(item.taxAmount || 0);
        const itemDiscount = Number(item.discountAmount || 0);

        orderItem.taxAmount = itemTax;
        orderItem.discountAmount = itemDiscount;

        const lineItemGross = itemUnitPrice * item.quantity;
        additionalSubtotal += lineItemGross;
        additionalTax += itemTax;
        additionalDiscount += itemDiscount;

        newOrderItems.push(orderItem);
        await manager.save(OrderItem, orderItem); // Save individual items
      }

      // Update Order Totals
      order.taxAmount = Number(order.taxAmount) + additionalTax;
      order.discountAmount = Number(order.discountAmount) + additionalDiscount;
      order.totalAmount =
        Number(order.totalAmount) +
        (additionalSubtotal - additionalDiscount + additionalTax);

      // Append items to the order object for return (optional, but good for response)
      if (!order.items) order.items = [];
      order.items.push(...newOrderItems);

      const savedOrder = await manager.save(Order, order);

      // Deduct Stock for new items
      await this.inventoryService.deductStockForOrder(stockCheckItems, manager);

      // Notify KDS
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
    return null; // Not implemented yet
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
