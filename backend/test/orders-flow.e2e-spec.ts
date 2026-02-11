import {
  CanActivate,
  ExecutionContext,
  INestApplication,
  Injectable,
} from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import { OrdersController } from '../src/modules/orders/orders.controller';
import {
  OrderStatus,
  OrderType,
  PaymentMethod,
  PaymentStatus,
} from '../src/modules/orders/order.entity';
import { OrdersService } from '../src/modules/orders/orders.service';
import { UsersService } from '../src/modules/users/users.service';
import { JwtAuthGuard } from '../src/modules/auth/guards/jwt-auth.guard';
import { UserRole } from '../src/modules/users/user.entity';

@Injectable()
class HeaderAuthGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest();
    const userId = req.headers['x-user-id'] as string | undefined;
    const role = req.headers['x-user-role'] as UserRole | undefined;
    if (!userId || !role) {
      return false;
    }
    req.user = { id: userId, role };
    return true;
  }
}

const usersById: Record<string, { id: string; role: UserRole }> = {
  admin1: { id: 'admin1', role: UserRole.ADMIN },
  manager1: { id: 'manager1', role: UserRole.MANAGER },
  cashier1: { id: 'cashier1', role: UserRole.CASHIER },
  waiter1: { id: 'waiter1', role: UserRole.WAITER },
  kitchen1: { id: 'kitchen1', role: UserRole.KITCHEN },
  driver1: { id: 'driver1', role: UserRole.DRIVER },
  driver2: { id: 'driver2', role: UserRole.DRIVER },
};

describe('Orders Flow (e2e)', () => {
  let app: INestApplication<App>;
  let orderCounter = 0;
  let refundCounter = 0;
  const orders = new Map<string, any>();
  const refunds = new Map<string, any>();

  const ordersServiceMock = {
    createOrder: jest.fn(async (body: any) => {
      orderCounter += 1;
      const id = `order-${orderCounter}`;
      const order = {
        id,
        type: body.type ?? OrderType.DELIVERY,
        status: OrderStatus.PENDING,
        paymentMethod: PaymentMethod.LATER,
        paymentStatus: PaymentStatus.PENDING,
        items: body.items ?? [],
        totalAmount: body.totalAmount ?? 50,
        taxAmount: 0,
        discountAmount: 0,
        customerId: body.customerId ?? null,
        table: null,
        driverId: null,
        deliveryAddress: body.deliveryAddress ?? null,
        deliveryFee: body.deliveryFee ?? 0,
        createdAt: new Date(),
      };
      orders.set(id, order);
      return order;
    }),
    findAll: jest.fn(async () => [...orders.values()]),
    findOne: jest.fn(async (id: string) => {
      const order = orders.get(id);
      if (!order) {
        throw new Error('Order not found');
      }
      return order;
    }),
    updateStatus: jest.fn(async (id: string, status: OrderStatus) => {
      const order = orders.get(id);
      order.status = status;
      return order;
    }),
    applyCoupon: jest.fn(async (id: string) => orders.get(id)),
    redeemPoints: jest.fn(async (id: string) => orders.get(id)),
    payOrder: jest.fn(async (id: string, paymentMethod: PaymentMethod) => {
      const order = orders.get(id);
      order.paymentMethod = paymentMethod;
      order.paymentStatus = PaymentStatus.PAID;
      order.status = OrderStatus.COMPLETED;
      return order;
    }),
    fireCourse: jest.fn(async (id: string) => orders.get(id)),
    assignDriver: jest.fn(async (id: string, driverId: string) => {
      const order = orders.get(id);
      order.driverId = driverId;
      order.status = OrderStatus.ON_DELIVERY;
      return order;
    }),
    findByDriver: jest.fn(async (driverId: string) =>
      [...orders.values()].filter((order) => order.driverId === driverId),
    ),
    requestRefund: jest.fn(
      async (orderId: string, amount: number, reason: string) => {
        refundCounter += 1;
        const refund = {
          id: `refund-${refundCounter}`,
          order: orders.get(orderId),
          amount,
          reason,
          status: 'PENDING',
        };
        refunds.set(refund.id, refund);
        return refund;
      },
    ),
    approveRefund: jest.fn(async (refundId: string, managerId: string) => {
      const refund = refunds.get(refundId);
      refund.status = 'APPROVED';
      refund.managerId = managerId;
      refund.order.status = OrderStatus.REFUNDED;
      return refund;
    }),
    rejectRefund: jest.fn(async (refundId: string, managerId: string) => {
      const refund = refunds.get(refundId);
      refund.status = 'REJECTED';
      refund.managerId = managerId;
      return refund;
    }),
    findPendingRefunds: jest.fn(async () =>
      [...refunds.values()].filter((refund) => refund.status === 'PENDING'),
    ),
    voidOrder: jest.fn(async (id: string) => {
      const order = orders.get(id);
      order.status = OrderStatus.VOIDED;
      return order;
    }),
  };

  const usersServiceMock = {
    findOneById: jest.fn(async (id: string) => usersById[id] ?? null),
  };

  function authHeaders(userId: string, role: UserRole) {
    return {
      'x-user-id': userId,
      'x-user-role': role,
    };
  }

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      controllers: [OrdersController],
      providers: [
        { provide: OrdersService, useValue: ordersServiceMock },
        { provide: UsersService, useValue: usersServiceMock },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useClass(HeaderAuthGuard)
      .compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  beforeEach(() => {
    orders.clear();
    refunds.clear();
    orderCounter = 0;
    refundCounter = 0;
    jest.clearAllMocks();
  });

  it('runs order lifecycle through refund approval', async () => {
    const createRes = await request(app.getHttpServer())
      .post('/orders')
      .set(authHeaders('cashier1', UserRole.CASHIER))
      .send({
        type: OrderType.DELIVERY,
        items: [{ productId: 'p1', quantity: 2 }],
        deliveryAddress: 'Main Street',
      })
      .expect(201);
    const orderId = createRes.body.id as string;

    await request(app.getHttpServer())
      .put(`/orders/${orderId}/status`)
      .set(authHeaders('kitchen1', UserRole.KITCHEN))
      .send({ status: OrderStatus.PREPARING })
      .expect(200);

    await request(app.getHttpServer())
      .put(`/orders/${orderId}/status`)
      .set(authHeaders('kitchen1', UserRole.KITCHEN))
      .send({ status: OrderStatus.READY })
      .expect(200);

    await request(app.getHttpServer())
      .post(`/orders/${orderId}/assign-driver`)
      .set(authHeaders('manager1', UserRole.MANAGER))
      .send({ driverId: 'driver1' })
      .expect(201);

    await request(app.getHttpServer())
      .put(`/orders/${orderId}/status`)
      .set(authHeaders('driver1', UserRole.DRIVER))
      .send({ status: OrderStatus.ON_DELIVERY })
      .expect(200);

    await request(app.getHttpServer())
      .put(`/orders/${orderId}/status`)
      .set(authHeaders('driver1', UserRole.DRIVER))
      .send({ status: OrderStatus.DELIVERED })
      .expect(200);

    await request(app.getHttpServer())
      .post(`/orders/${orderId}/pay`)
      .set(authHeaders('cashier1', UserRole.CASHIER))
      .send({ paymentMethod: PaymentMethod.CASH })
      .expect(201);

    await request(app.getHttpServer())
      .post(`/orders/${orderId}/refund`)
      .set(authHeaders('cashier1', UserRole.CASHIER))
      .send({ amount: 10, reason: 'Customer complaint' })
      .expect(201);

    const pendingRefundsRes = await request(app.getHttpServer())
      .get('/orders/refunds/pending')
      .set(authHeaders('manager1', UserRole.MANAGER))
      .expect(200);

    const refundId = pendingRefundsRes.body[0].id as string;
    await request(app.getHttpServer())
      .post(`/orders/refunds/${refundId}/approve`)
      .set(authHeaders('manager1', UserRole.MANAGER))
      .expect(201);

    const getOrderRes = await request(app.getHttpServer())
      .get(`/orders/${orderId}`)
      .set(authHeaders('manager1', UserRole.MANAGER))
      .expect(200);
    expect(getOrderRes.body.status).toBe(OrderStatus.REFUNDED);
  });

  it('prevents a driver from updating another driver order', async () => {
    const createRes = await request(app.getHttpServer())
      .post('/orders')
      .set(authHeaders('cashier1', UserRole.CASHIER))
      .send({
        type: OrderType.DELIVERY,
        items: [{ productId: 'p1', quantity: 1 }],
      })
      .expect(201);
    const orderId = createRes.body.id as string;

    await request(app.getHttpServer())
      .post(`/orders/${orderId}/assign-driver`)
      .set(authHeaders('manager1', UserRole.MANAGER))
      .send({ driverId: 'driver1' })
      .expect(201);

    await request(app.getHttpServer())
      .put(`/orders/${orderId}/status`)
      .set(authHeaders('driver2', UserRole.DRIVER))
      .send({ status: OrderStatus.DELIVERED })
      .expect(403);
  });

  it('prevents non-manager roles from approving refunds', async () => {
    const createRes = await request(app.getHttpServer())
      .post('/orders')
      .set(authHeaders('cashier1', UserRole.CASHIER))
      .send({
        type: OrderType.DELIVERY,
        items: [{ productId: 'p1', quantity: 1 }],
      })
      .expect(201);
    const orderId = createRes.body.id as string;

    const refundRes = await request(app.getHttpServer())
      .post(`/orders/${orderId}/refund`)
      .set(authHeaders('cashier1', UserRole.CASHIER))
      .send({ amount: 5, reason: 'Test' })
      .expect(201);

    await request(app.getHttpServer())
      .post(`/orders/refunds/${refundRes.body.id}/approve`)
      .set(authHeaders('cashier1', UserRole.CASHIER))
      .expect(403);
  });
});
