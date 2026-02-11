import { OrderStatus } from './order.entity';
import {
  canTransitionOrderItemStatus,
  canTransitionOrderStatus,
  isFinalOrderStatus,
  isOrderItemStatus,
} from './order-status.workflow';

describe('order-status workflow', () => {
  it('allows valid order transitions', () => {
    expect(
      canTransitionOrderStatus(OrderStatus.PENDING, OrderStatus.PREPARING),
    ).toBe(true);
    expect(
      canTransitionOrderStatus(OrderStatus.READY, OrderStatus.ON_DELIVERY),
    ).toBe(true);
    expect(
      canTransitionOrderStatus(OrderStatus.DELIVERED, OrderStatus.COMPLETED),
    ).toBe(true);
  });

  it('blocks invalid order transitions', () => {
    expect(
      canTransitionOrderStatus(OrderStatus.CANCELLED, OrderStatus.PREPARING),
    ).toBe(false);
    expect(
      canTransitionOrderStatus(OrderStatus.VOIDED, OrderStatus.COMPLETED),
    ).toBe(false);
    expect(
      canTransitionOrderStatus(OrderStatus.PENDING, OrderStatus.DELIVERED),
    ).toBe(false);
  });

  it('marks final statuses correctly', () => {
    expect(isFinalOrderStatus(OrderStatus.COMPLETED)).toBe(true);
    expect(isFinalOrderStatus(OrderStatus.CANCELLED)).toBe(true);
    expect(isFinalOrderStatus(OrderStatus.REFUNDED)).toBe(true);
    expect(isFinalOrderStatus(OrderStatus.PREPARING)).toBe(false);
  });

  it('validates order item statuses and transitions', () => {
    expect(isOrderItemStatus('PENDING')).toBe(true);
    expect(isOrderItemStatus('INVALID')).toBe(false);

    expect(canTransitionOrderItemStatus('PENDING', 'PREPARING')).toBe(true);
    expect(canTransitionOrderItemStatus('READY', 'SERVED')).toBe(true);
    expect(canTransitionOrderItemStatus('SERVED', 'READY')).toBe(false);
  });
});
