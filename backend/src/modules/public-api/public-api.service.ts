import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { TablesService } from '../tables/tables.service';
import { CatalogService } from '../catalog/catalog.service';
import { OrdersService } from '../orders/orders.service';
import {
  Order,
  OrderSource,
  OrderType,
  PaymentMethod,
} from '../orders/order.entity';
import { PublicOrderItemDto } from './dto/public-order.dto';

@Injectable()
export class PublicApiService {
  constructor(
    private tablesService: TablesService,
    private catalogService: CatalogService,
    private ordersService: OrdersService,
  ) {}

  private normalizePublicItems(items: PublicOrderItemDto[]) {
    return items.map((item) => ({
      productId: item.productId,
      quantity: Number(item.quantity),
      notes: item.notes,
      // Keep only IDs. Pricing and validity are enforced server-side from DB.
      modifiers: (item.modifiers || []).map((modifier) => ({
        id: modifier.id,
      })),
    }));
  }

  async validateTableToken(token: string) {
    const normalizedToken = typeof token === 'string' ? token.trim() : '';
    if (!normalizedToken) {
      throw new BadRequestException('Table token is required');
    }
    return this.tablesService.findByQrCode(normalizedToken);
  }

  async getMenu(token: string) {
    const table = await this.validateTableToken(token);
    const categories = await this.catalogService.findAllCategories();
    const filteredCategories = categories
      .map((category) => ({
        ...category,
        products: (category.products || []).filter(
          (product) => product.isAvailable,
        ),
      }))
      .filter((category) => category.products.length > 0);

    return {
      branchName: process.env.PUBLIC_BRANCH_NAME || 'Main Branch',
      tableNumber: table.tableNumber,
      categories: filteredCategories,
    };
  }

  async getActiveOrder(token: string) {
    const table = await this.validateTableToken(token);
    return this.ordersService.findActiveOrderForTable(table.id);
  }

  async createOrder(token: string, orderData: any): Promise<Order> {
    const table = await this.validateTableToken(token);
    const items = this.normalizePublicItems(orderData.items || []);
    if (items.length === 0) {
      throw new BadRequestException('Order must contain at least one item');
    }

    const createOrderDto = {
      items,
      tableId: table.id,
      type: OrderType.DINE_IN,
      paymentMethod: PaymentMethod.LATER,
      source: OrderSource.SELF_ORDER,
    };

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

    const normalizedItems = this.normalizePublicItems(items || []);
    if (normalizedItems.length === 0) {
      throw new BadRequestException('Items are required');
    }

    return this.ordersService.addItemsToOrder(publicId, normalizedItems);
  }

  async requestBill(token: string) {
    const table = await this.validateTableToken(token);
    this.ordersService.notifyBillRequest(table);
    return { success: true, message: 'Bill requested' };
  }
}
