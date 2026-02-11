import { Test, TestingModule } from '@nestjs/testing';
import { PublicApiService } from './public-api.service';
import { TablesService } from '../tables/tables.service';
import { CatalogService } from '../catalog/catalog.service';
import { OrdersService } from '../orders/orders.service';
import { OrderSource, OrderType, PaymentMethod } from '../orders/order.entity';

describe('PublicApiService', () => {
  let service: PublicApiService;

  const tablesServiceMock = {
    findByQrCode: jest.fn(),
  };

  const catalogServiceMock = {
    findAllCategories: jest.fn(),
  };

  const ordersServiceMock = {
    createOrder: jest.fn(),
    findOne: jest.fn(),
    addItemsToOrder: jest.fn(),
    findActiveOrderForTable: jest.fn(),
    notifyBillRequest: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PublicApiService,
        { provide: TablesService, useValue: tablesServiceMock },
        { provide: CatalogService, useValue: catalogServiceMock },
        { provide: OrdersService, useValue: ordersServiceMock },
      ],
    }).compile();

    service = module.get<PublicApiService>(PublicApiService);
    jest.clearAllMocks();
  });

  it('enforces self-order defaults and strips modifier payloads', async () => {
    tablesServiceMock.findByQrCode.mockResolvedValue({
      id: 'table-1',
      tableNumber: 'A1',
    });
    ordersServiceMock.createOrder.mockResolvedValue({ id: 'order-1' });

    await service.createOrder('token-1', {
      items: [
        {
          productId: 'product-1',
          quantity: 2,
          notes: 'No onions',
          modifiers: [{ id: 'mod-1', price: -999 }],
        },
      ],
      paymentMethod: PaymentMethod.CASH,
      type: OrderType.DELIVERY,
    });

    expect(ordersServiceMock.createOrder).toHaveBeenCalledWith({
      items: [
        {
          productId: 'product-1',
          quantity: 2,
          notes: 'No onions',
          modifiers: [{ id: 'mod-1' }],
        },
      ],
      tableId: 'table-1',
      type: OrderType.DINE_IN,
      paymentMethod: PaymentMethod.LATER,
      source: OrderSource.SELF_ORDER,
    });
  });

  it('returns only available products in public menu', async () => {
    tablesServiceMock.findByQrCode.mockResolvedValue({
      id: 'table-1',
      tableNumber: 'A1',
    });
    catalogServiceMock.findAllCategories.mockResolvedValue([
      {
        id: 'cat-1',
        name: { en: 'Coffee', ar: 'قهوة' },
        products: [
          { id: 'p1', isAvailable: true },
          { id: 'p2', isAvailable: false },
        ],
      },
      {
        id: 'cat-2',
        name: { en: 'Desserts', ar: 'حلويات' },
        products: [{ id: 'p3', isAvailable: false }],
      },
    ]);

    const result = await service.getMenu('token-1');

    expect(result.tableNumber).toBe('A1');
    expect(result.categories).toHaveLength(1);
    expect(result.categories[0].id).toBe('cat-1');
    expect(result.categories[0].products).toHaveLength(1);
    expect(result.categories[0].products[0].id).toBe('p1');
  });
});
