import { BadRequestException } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { OrderStatus, OrderType } from './order.entity';

describe('OrdersService guards', () => {
  const createService = () => {
    const ordersRepository = { save: jest.fn() };
    const orderItemsRepository = {};
    const productsRepository = {};
    const tablesRepository = { findOneBy: jest.fn(), findOne: jest.fn() };
    const refundsRepository = {};
    const inventoryService = { checkStockAvailability: jest.fn() };
    const ordersGateway = { notifyOrderUpdate: jest.fn(), notifyNewOrder: jest.fn() };
    const customersService = { findOne: jest.fn(), addPoints: jest.fn() };
    const couponsService = {};
    const shiftsService = {};
    const dataSource = { transaction: jest.fn() };

    const service = new OrdersService(
      ordersRepository as any,
      orderItemsRepository as any,
      productsRepository as any,
      tablesRepository as any,
      refundsRepository as any,
      inventoryService as any,
      ordersGateway as any,
      customersService as any,
      couponsService as any,
      shiftsService as any,
      dataSource as any,
    );

    return {
      service,
      customersService,
    };
  };

  it('rejects redeeming non-positive points', async () => {
    const { service, customersService } = createService();
    jest.spyOn(service, 'findOne').mockResolvedValue({
      id: 'o1',
      customerId: 'c1',
      status: OrderStatus.PENDING,
      totalAmount: 50,
      discountAmount: 0,
      redeemedPoints: 0,
    } as any);

    await expect(service.redeemPoints('o1', 0)).rejects.toThrow(
      BadRequestException,
    );
    expect(customersService.findOne).not.toHaveBeenCalled();
  });

  it('rejects redeeming fractional points', async () => {
    const { service, customersService } = createService();
    jest.spyOn(service, 'findOne').mockResolvedValue({
      id: 'o1',
      customerId: 'c1',
      status: OrderStatus.PENDING,
      totalAmount: 50,
      discountAmount: 0,
      redeemedPoints: 0,
    } as any);

    await expect(service.redeemPoints('o1', 1.5)).rejects.toThrow(
      BadRequestException,
    );
    expect(customersService.findOne).not.toHaveBeenCalled();
  });

  it('rejects delivery orders without delivery address', async () => {
    const { service } = createService();
    await expect(
      service.createOrder({
        type: OrderType.DELIVERY,
        items: [{ productId: 'p1', quantity: 1 }],
      }),
    ).rejects.toThrow(BadRequestException);
  });

  it('rejects delivery fee for non-delivery orders', async () => {
    const { service } = createService();
    await expect(
      service.createOrder({
        type: OrderType.TAKEAWAY,
        deliveryFee: 5,
        items: [{ productId: 'p1', quantity: 1 }],
      }),
    ).rejects.toThrow(BadRequestException);
  });
});
