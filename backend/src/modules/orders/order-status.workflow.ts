import { OrderStatus } from './order.entity';

export type OrderItemStatus = 'PENDING' | 'PREPARING' | 'READY' | 'SERVED';

const ORDER_STATUS_TRANSITIONS: Readonly<
  Record<OrderStatus, readonly OrderStatus[]>
> = {
  [OrderStatus.PENDING]: [
    OrderStatus.PREPARING,
    OrderStatus.HELD,
    OrderStatus.CANCELLED,
    OrderStatus.VOIDED,
    OrderStatus.COMPLETED,
  ],
  [OrderStatus.PREPARING]: [
    OrderStatus.READY,
    OrderStatus.HELD,
    OrderStatus.CANCELLED,
    OrderStatus.VOIDED,
    OrderStatus.COMPLETED,
  ],
  [OrderStatus.READY]: [
    OrderStatus.SERVED,
    OrderStatus.ON_DELIVERY,
    OrderStatus.CANCELLED,
    OrderStatus.VOIDED,
    OrderStatus.COMPLETED,
  ],
  [OrderStatus.SERVED]: [OrderStatus.COMPLETED, OrderStatus.REFUNDED],
  [OrderStatus.COMPLETED]: [OrderStatus.REFUNDED],
  [OrderStatus.CANCELLED]: [],
  [OrderStatus.HELD]: [
    OrderStatus.PENDING,
    OrderStatus.PREPARING,
    OrderStatus.CANCELLED,
    OrderStatus.VOIDED,
  ],
  [OrderStatus.ON_DELIVERY]: [OrderStatus.DELIVERED, OrderStatus.CANCELLED],
  [OrderStatus.DELIVERED]: [OrderStatus.COMPLETED, OrderStatus.REFUNDED],
  [OrderStatus.REFUNDED]: [],
  [OrderStatus.VOIDED]: [],
};

const ORDER_ITEM_STATUS_TRANSITIONS: Readonly<
  Record<OrderItemStatus, readonly OrderItemStatus[]>
> = {
  PENDING: ['PREPARING'],
  PREPARING: ['READY'],
  READY: ['SERVED'],
  SERVED: [],
};

const FINAL_ORDER_STATUSES = new Set<OrderStatus>([
  OrderStatus.COMPLETED,
  OrderStatus.CANCELLED,
  OrderStatus.REFUNDED,
  OrderStatus.VOIDED,
]);

export function isFinalOrderStatus(status: OrderStatus): boolean {
  return FINAL_ORDER_STATUSES.has(status);
}

export function canTransitionOrderStatus(
  from: OrderStatus,
  to: OrderStatus,
): boolean {
  if (from === to) {
    return true;
  }

  return ORDER_STATUS_TRANSITIONS[from].includes(to);
}

export function isOrderItemStatus(value: string): value is OrderItemStatus {
  return (
    value === 'PENDING' ||
    value === 'PREPARING' ||
    value === 'READY' ||
    value === 'SERVED'
  );
}

export function canTransitionOrderItemStatus(
  from: OrderItemStatus,
  to: OrderItemStatus,
): boolean {
  if (from === to) {
    return true;
  }
  return ORDER_ITEM_STATUS_TRANSITIONS[from].includes(to);
}
