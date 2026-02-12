import { BadRequestException, NotFoundException } from '@nestjs/common';
import { DeliveryService } from './delivery.service';
import { OrderStatus, OrderType } from '../orders/order.entity';

describe('DeliveryService', () => {
  const createService = () => {
    const ordersService = {
      updateDeliveryInfo: jest.fn(),
      findOne: jest.fn(),
      findByDeliveryReferenceId: jest.fn(),
      updateStatus: jest.fn(),
    };
    const service = new DeliveryService(ordersService as any);
    return { service, ordersService };
  };

  it('persists provider and reference id when requesting delivery', async () => {
    const { service, ordersService } = createService();
    const order = {
      id: 'order-1',
      type: OrderType.DELIVERY,
      deliveryAddress: 'Main St',
    };

    const referenceId = await service.requestDelivery('mock-aggregator', order as any);

    expect(referenceId).toContain('MOCK-');
    expect(ordersService.updateDeliveryInfo).toHaveBeenCalledWith('order-1', {
      deliveryProvider: 'mock-aggregator',
      deliveryReferenceId: referenceId,
    });
  });

  it('rejects requesting delivery for non-delivery orders', async () => {
    const { service } = createService();
    await expect(
      service.requestDelivery('mock-aggregator', {
        id: 'order-1',
        type: OrderType.DINE_IN,
        deliveryAddress: 'Main St',
      } as any),
    ).rejects.toThrow(BadRequestException);
  });

  it('rejects webhook payload without orderId and referenceId', async () => {
    const { service } = createService();
    await expect(
      service.handleWebhook('mock-aggregator', { status: 'ASSIGNED' }),
    ).rejects.toThrow(BadRequestException);
  });

  it('maps PICKED_UP webhook to ON_DELIVERY', async () => {
    const { service, ordersService } = createService();
    ordersService.findByDeliveryReferenceId.mockResolvedValue({
      id: 'order-1',
      status: OrderStatus.READY,
    });
    ordersService.updateStatus.mockResolvedValue({
      id: 'order-1',
      status: OrderStatus.ON_DELIVERY,
    });

    await service.handleWebhook('mock-aggregator', {
      referenceId: 'ref-1',
      status: 'PICKED_UP',
    });

    expect(ordersService.updateStatus).toHaveBeenCalledWith(
      'order-1',
      OrderStatus.ON_DELIVERY,
    );
  });

  it('throws for unknown provider', async () => {
    const { service } = createService();
    await expect(
      service.handleWebhook('unknown-provider', {
        orderId: 'order-1',
        status: 'ASSIGNED',
      }),
    ).rejects.toThrow(NotFoundException);
  });
});
