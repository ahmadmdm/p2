import { Logger } from '@nestjs/common';
import { DeliveryProvider } from '../interfaces/delivery-provider.interface';
import { Order } from '../../orders/order.entity';

export class MockAggregatorProvider implements DeliveryProvider {
  name = 'mock-aggregator';
  private readonly logger = new Logger(MockAggregatorProvider.name);

  async checkServiceability(address: any): Promise<boolean> {
    this.logger.log(
      `Checking serviceability for address: ${JSON.stringify(address)}`,
    );
    return true;
  }

  async requestDelivery(order: Order): Promise<string> {
    this.logger.log(`Requesting delivery for order ${order.id}`);
    const referenceId = `MOCK-${Date.now()}-${order.id.substring(0, 8)}`;
    this.logger.log(`Delivery requested. Reference ID: ${referenceId}`);
    return referenceId;
  }

  async cancelDelivery(referenceId: string): Promise<boolean> {
    this.logger.log(`Cancelling delivery ${referenceId}`);
    return true;
  }

  async getDeliveryStatus(referenceId: string): Promise<any> {
    this.logger.debug(`Checking mock status for delivery ${referenceId}`);
    return {
      status: 'driver_assigned',
      driver: { name: 'John Doe', phone: '555-0123' },
    };
  }
}
