import { Controller, Post, Body, Param, Logger } from '@nestjs/common';
import { DeliveryService } from './delivery.service';

@Controller('delivery')
export class DeliveryController {
  private readonly logger = new Logger(DeliveryController.name);

  constructor(private readonly deliveryService: DeliveryService) {}

  @Post('request/:orderId')
  async requestDelivery(
    @Param('orderId') orderId: string,
    @Body('provider') providerName: string,
  ) {
    const order = await this.deliveryService.getOrder(orderId);
    if (!order) {
      throw new Error('Order not found');
    }
    const referenceId = await this.deliveryService.requestDelivery(
      providerName || 'mock-aggregator',
      order,
    );
    return { success: true, referenceId };
  }

  @Post('cancel/:orderId')
  async cancelDelivery(@Param('orderId') orderId: string) {
    const success = await this.deliveryService.cancelDeliveryForOrder(orderId);
    return { success };
  }

  @Post('webhook/:provider')
  async handleWebhook(
    @Param('provider') provider: string,
    @Body() payload: any,
  ) {
    await this.deliveryService.handleWebhook(provider, payload);
    return { success: true };
  }
}
