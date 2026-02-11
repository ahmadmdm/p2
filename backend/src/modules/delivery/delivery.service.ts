import {
  Injectable,
  Logger,
  Inject,
  forwardRef,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { DeliveryProvider } from './interfaces/delivery-provider.interface';
import { MockAggregatorProvider } from './providers/mock-aggregator.provider';
import { UberEatsProvider } from './providers/uber-eats.provider';
import { Order } from '../orders/order.entity';
import { OrdersService } from '../orders/orders.service';

@Injectable()
export class DeliveryService {
  private readonly logger = new Logger(DeliveryService.name);
  private providers: Map<string, DeliveryProvider> = new Map();

  constructor(
    @Inject(forwardRef(() => OrdersService))
    private readonly ordersService: OrdersService,
  ) {
    // Register providers
    this.registerProvider(new MockAggregatorProvider());
    this.registerProvider(new UberEatsProvider());
  }

  registerProvider(provider: DeliveryProvider) {
    this.providers.set(provider.name, provider);
    this.logger.log(`Registered delivery provider: ${provider.name}`);
  }

  getProvider(name: string): DeliveryProvider {
    const provider = this.providers.get(name);
    if (!provider) {
      throw new NotFoundException(`Delivery provider ${name} not found`);
    }
    return provider;
  }

  async requestDelivery(providerName: string, order: Order): Promise<string> {
    const provider = this.getProvider(providerName);
    const referenceId = await provider.requestDelivery(order);

    await this.ordersService.updateDeliveryInfo(order.id, {
      deliveryProvider: providerName,
      deliveryReferenceId: referenceId,
    });

    return referenceId;
  }

  async cancelDelivery(
    providerName: string,
    referenceId: string,
  ): Promise<boolean> {
    const provider = this.getProvider(providerName);
    return provider.cancelDelivery(referenceId);
  }

  async cancelDeliveryForOrder(orderId: string): Promise<boolean> {
    const order = await this.ordersService.findOne(orderId);
    if (!order) throw new NotFoundException('Order not found');
    if (!order.deliveryProvider || !order.deliveryReferenceId) {
      throw new BadRequestException('Order has no delivery info');
    }
    return this.cancelDelivery(
      order.deliveryProvider,
      order.deliveryReferenceId,
    );
  }

  async getOrder(orderId: string): Promise<Order | null> {
    return this.ordersService.findOne(orderId);
  }

  async handleWebhook(providerName: string, payload: any) {
    this.logger.log(
      `Handling webhook for ${providerName}: ${JSON.stringify(payload)}`,
    );

    // Generic handling logic
    const { referenceId, status, orderId } = payload;

    // Find order by referenceId or orderId
    let order: Order | null = null;

    if (orderId) {
      order = await this.ordersService.findOne(orderId);
    } else if (referenceId) {
      // We need a method to find by deliveryReferenceId in OrdersService
      // For now, let's assume we can't easily find by refId without adding an index/method
      // So we rely on orderId being present in payload or we scan (bad for perf)
      // Let's try to query via repository if possible, but OrdersService is better encapsulation.
      // Assuming OrdersService has a method or we add one.
      // Let's add findByDeliveryReferenceId to OrdersService.
      order = await this.ordersService.findByDeliveryReferenceId(referenceId);
    }

    if (order) {
      let orderStatus = 'PREPARING';
      if (status === 'ASSIGNED') orderStatus = 'READY';
      if (status === 'PICKED_UP') orderStatus = 'SERVED'; // Or DELIVERING if we add that status
      if (status === 'DELIVERED') orderStatus = 'COMPLETED';
      if (status === 'CANCELLED') orderStatus = 'CANCELLED';

      await this.ordersService.updateStatus(order.id, orderStatus as any);
      this.logger.log(`Updated order ${order.id} to ${orderStatus}`);
    } else {
      this.logger.warn(
        `Order not found for webhook: ${JSON.stringify(payload)}`,
      );
    }
  }
}
