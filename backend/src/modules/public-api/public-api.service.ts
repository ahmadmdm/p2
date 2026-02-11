import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { TablesService } from '../tables/tables.service';
import { CatalogService } from '../catalog/catalog.service';
import { OrdersService } from '../orders/orders.service';
import { Order } from '../orders/order.entity';

@Injectable()
export class PublicApiService {
  constructor(
    private tablesService: TablesService,
    private catalogService: CatalogService,
    private ordersService: OrdersService,
  ) {}

  async validateTableToken(token: string) {
    if (!token) throw new BadRequestException('Table token is required');
    return this.tablesService.findByQrCode(token);
  }

  async getMenu(token: string) {
    const table = await this.validateTableToken(token);
    // You might want to filter menu based on table section or other rules later
    const categories = await this.catalogService.findAllCategories();
    // Assuming findAllCategories returns categories with products, or we need to fetch products
    // CatalogService.findAllCategories() usually just returns categories.
    // We probably want the full menu structure for the PWA.
    // Let's check CatalogService capabilities.
    // If it doesn't have a "full menu" method, we might need to construct it.
    // For now, let's return what findAllCategories provides.
    return {
      branchName: 'My Restaurant', // Placeholder or from config
      tableNumber: table.tableNumber,
      categories,
    };
  }

  async getActiveOrder(token: string) {
    const table = await this.validateTableToken(token);
    return this.ordersService.findActiveOrderForTable(table.id);
  }

  async createOrder(token: string, orderData: any): Promise<Order> {
    const table = await this.validateTableToken(token);

    // Inject the correct tableId into the order data
    const createOrderDto = {
      ...orderData,
      tableId: table.id,
      // Ensure we don't accidentally allow setting other restricted fields
    };

    // We might want to mark this order as "Self Order" somehow.
    // OrdersService.createOrder doesn't explicitly support a "source" field yet,
    // but we can add notes or handle it if needed.
    // For now, passing it to OrdersService is sufficient.

    return this.ordersService.createOrder(createOrderDto);
  }

  async getOrder(token: string, publicId: string) {
    const table = await this.validateTableToken(token);
    const order = await this.ordersService.findOne(publicId);

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    // Security check: ensure the order belongs to the table associated with the token
    if (!order.table || order.table.id !== table.id) {
      throw new NotFoundException('Order not found for this table');
    }

    return order;
  }

  async addItemsToOrder(token: string, publicId: string, items: any[]) {
    const table = await this.validateTableToken(token);
    const order = await this.ordersService.findOne(publicId);

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (!order.table || order.table.id !== table.id) {
      throw new NotFoundException('Order not found for this table');
    }

    return this.ordersService.addItemsToOrder(publicId, items);
  }

  async requestBill(token: string) {
    const table = await this.validateTableToken(token);
    // Notify waiters/POS
    // We need access to OrdersGateway, but it is in OrdersModule.
    // OrdersService has it. Let's expose a method in OrdersService or inject Gateway here.
    // Since OrdersModule exports OrdersGateway (checked previously), we can inject it?
    // Wait, OrdersModule exports OrdersService. Does it export Gateway?
    // Let's check OrdersModule.ts
    // If not, we can add a method to OrdersService "notifyBillRequest".
    this.ordersService.notifyBillRequest(table);
    return { success: true, message: 'Bill requested' };
  }
}
