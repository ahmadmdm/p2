import { BadRequestException } from '@nestjs/common';
import { PurchasingService } from './purchasing.service';
import { PurchaseOrderStatus } from './purchase-order.entity';

describe('PurchasingService', () => {
  const createService = () => {
    const poRepository = { create: jest.fn(), save: jest.fn(), findOne: jest.fn() };
    const poItemRepository = { create: jest.fn(), save: jest.fn(), findOne: jest.fn(), remove: jest.fn() };
    const inventoryService = { updateStock: jest.fn() };
    const dataSource = {
      transaction: jest.fn(async (cb: (manager: any) => Promise<any>) =>
        cb({ save: jest.fn(async (value: any) => value) }),
      ),
    };

    const service = new PurchasingService(
      poRepository as any,
      poItemRepository as any,
      inventoryService as any,
      dataSource as any,
    );

    return { service, poRepository, poItemRepository, inventoryService, dataSource };
  };

  it('requires supplier id when creating purchase order', async () => {
    const { service } = createService();
    await expect(service.create({ notes: 'x' } as any)).rejects.toThrow(
      BadRequestException,
    );
  });

  it('rejects invalid item quantity', async () => {
    const { service } = createService();
    jest.spyOn(service, 'findOne').mockResolvedValue({
      id: 'po-1',
      status: PurchaseOrderStatus.DRAFT,
      items: [],
    } as any);

    await expect(
      service.addItem('po-1', {
        ingredientId: 'ing-1',
        quantity: 0,
        unitPrice: 12,
      } as any),
    ).rejects.toThrow(BadRequestException);
  });

  it('rejects invalid status transition from draft to received', async () => {
    const { service } = createService();
    jest.spyOn(service, 'findOne').mockResolvedValue({
      id: 'po-1',
      status: PurchaseOrderStatus.DRAFT,
      items: [{ ingredientId: 'ing-1', quantity: 2 }],
    } as any);

    await expect(
      service.updateStatus('po-1', PurchaseOrderStatus.RECEIVED),
    ).rejects.toThrow(BadRequestException);
  });

  it('rejects receiving ordered purchase order with no items', async () => {
    const { service } = createService();
    jest.spyOn(service, 'findOne').mockResolvedValue({
      id: 'po-1',
      status: PurchaseOrderStatus.ORDERED,
      items: [],
    } as any);

    await expect(
      service.updateStatus('po-1', PurchaseOrderStatus.RECEIVED),
    ).rejects.toThrow(BadRequestException);
  });

  it('restocks inventory when receiving ordered purchase order', async () => {
    const { service, inventoryService } = createService();
    jest.spyOn(service, 'findOne').mockResolvedValue({
      id: 'po-1',
      status: PurchaseOrderStatus.ORDERED,
      items: [{ ingredientId: 'ing-1', quantity: 3 }],
    } as any);

    await service.updateStatus('po-1', PurchaseOrderStatus.RECEIVED);

    expect(inventoryService.updateStock).toHaveBeenCalledWith(
      'ing-1',
      3,
      expect.any(Object),
      undefined,
      'RESTOCK',
      'po-1',
      'PO po-1 received',
    );
  });
});
