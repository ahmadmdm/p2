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
import { canTransitionOrderStatus } from '../orders/order-status.workflow';
import { Order, OrderStatus, OrderType } from '../orders/order.entity';
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

  private normalizeProviderName(value: string): string {
    return typeof value === 'string' ? value.trim() : '';
  }

  private mapExternalStatusToOrderStatus(status: string): OrderStatus | null {
    switch ((status || '').toUpperCase()) {
      case 'ASSIGNED':
      case 'ACCEPTED':
      case 'PREPARING':
        return OrderStatus.PREPARING;
      case 'PICKED_UP':
      case 'IN_TRANSIT':
      case 'ON_THE_WAY':
        return OrderStatus.ON_DELIVERY;
      case 'DELIVERED':
        return OrderStatus.DELIVERED;
      case 'CANCELLED':
        return OrderStatus.CANCELLED;
      default:
        return null;
    }
  }

  getProvider(name: string): DeliveryProvider {
    const provider = this.providers.get(name);
    if (!provider) {
      throw new NotFoundException(`Delivery provider ${name} not found`);
    }
    return provider;
  }

  async requestDelivery(providerName: string, order: Order): Promise<string> {
    if (order.type !== OrderType.DELIVERY) {
      throw new BadRequestException(
        'Delivery can only be requested for delivery orders',
      );
    }
    if (!order.deliveryAddress?.trim()) {
      throw new BadRequestException('Delivery address is required');
    }

    const normalizedProvider = this.normalizeProviderName(providerName);
    const provider = this.getProvider(normalizedProvider);
    const referenceId = await provider.requestDelivery(order);

    await this.ordersService.updateDeliveryInfo(order.id, {
      deliveryProvider: normalizedProvider,
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
    const normalizedProvider = this.normalizeProviderName(providerName);
    this.getProvider(normalizedProvider);

    if (!payload || typeof payload !== 'object') {
      throw new BadRequestException('Invalid webhook payload');
    }

    this.logger.log(
      `Handling webhook for ${normalizedProvider}: ${JSON.stringify(payload)}`,
    );

    // Generic handling logic
    const { referenceId, status, orderId } = payload;
    if (!orderId && !referenceId) {
      throw new BadRequestException(
        'Webhook payload must include orderId or referenceId',
      );
    }
    if (!status || typeof status !== 'string') {
      throw new BadRequestException('Webhook payload status is required');
    }

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
      const targetStatus = this.mapExternalStatusToOrderStatus(status);
      if (!targetStatus) {
        this.logger.warn(`Unhandled delivery webhook status: ${status}`);
        return;
      }

      if (order.status === targetStatus) {
        return;
      }

      // If provider says delivered and order is still READY, move via ON_DELIVERY first.
      if (
        targetStatus === OrderStatus.DELIVERED &&
        order.status === OrderStatus.READY
      ) {
        try {
          if (canTransitionOrderStatus(order.status, OrderStatus.ON_DELIVERY)) {
            order = await this.ordersService.updateStatus(
              order.id,
              OrderStatus.ON_DELIVERY,
            );
          }
        } catch (error) {
          this.logger.warn(
            `Failed intermediate status update for order ${order.id}: ${String(error)}`,
          );
        }
      }

      if (!canTransitionOrderStatus(order.status, targetStatus)) {
        this.logger.warn(
          `Skipping invalid delivery status transition for order ${order.id}: ${order.status} -> ${targetStatus}`,
        );
        return;
      }

      await this.ordersService.updateStatus(order.id, targetStatus);
      this.logger.log(`Updated order ${order.id} to ${targetStatus}`);
    } else {
      this.logger.warn(
        `Order not found for webhook: ${JSON.stringify(payload)}`,
      );
    }
  }
}
