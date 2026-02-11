import { Order } from '../../orders/order.entity';

export interface DeliveryProvider {
  name: string;

  /**
   * Validate if the address is deliverable
   */
  checkServiceability(address: any): Promise<boolean>;

  /**
   * Request a delivery driver for an order
   */
  requestDelivery(order: Order): Promise<string>; // Returns external reference ID

  /**
   * Cancel a delivery request
   */
  cancelDelivery(referenceId: string): Promise<boolean>;

  /**
   * Get current status of the delivery
   */
  getDeliveryStatus(referenceId: string): Promise<any>;
}
