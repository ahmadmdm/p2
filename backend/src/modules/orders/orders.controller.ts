import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Put,
  Request,
  ForbiddenException,
  BadRequestException,
  UseGuards,
  UnauthorizedException,
} from '@nestjs/common';
import { OrdersService } from './orders.service';
import { OrderStatus, PaymentMethod } from './order.entity';
import { CreateOrderDto } from './dto/create-order.dto';
import { UsersService } from '../users/users.service';
import { UserRole } from '../users/user.entity';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('orders')
@UseGuards(JwtAuthGuard)
export class OrdersController {
  constructor(
    private readonly ordersService: OrdersService,
    private readonly usersService: UsersService,
  ) {}

  private async getRequestUser(req: any) {
    const userId = req.user?.id;
    if (!userId) {
      throw new UnauthorizedException('User not authenticated');
    }
    const user = await this.usersService.findOneById(userId);
    if (!user) {
      throw new UnauthorizedException('User not found');
    }
    return user;
  }

  private ensureRole(
    role: UserRole,
    allowed: UserRole[],
    message: string,
  ): void {
    if (!allowed.includes(role)) {
      throw new ForbiddenException(message);
    }
  }

  @Post()
  async createOrder(@Body() body: CreateOrderDto, @Request() req: any) {
    const user = await this.getRequestUser(req);
    this.ensureRole(
      user.role,
      [UserRole.ADMIN, UserRole.MANAGER, UserRole.CASHIER, UserRole.WAITER],
      'Only cashier, waiter, manager, and admin can create orders',
    );
    return this.ordersService.createOrder(body, user.id);
  }

  @Get()
  async getOrders(@Request() req: any) {
    const user = await this.getRequestUser(req);
    this.ensureRole(
      user.role,
      [
        UserRole.ADMIN,
        UserRole.MANAGER,
        UserRole.CASHIER,
        UserRole.WAITER,
        UserRole.KITCHEN,
        UserRole.DRIVER,
      ],
      'Access denied',
    );
    return this.ordersService.findAll();
  }

  @Get(':id')
  async getOrder(@Param('id') id: string, @Request() req: any) {
    const user = await this.getRequestUser(req);
    this.ensureRole(
      user.role,
      [
        UserRole.ADMIN,
        UserRole.MANAGER,
        UserRole.CASHIER,
        UserRole.WAITER,
        UserRole.KITCHEN,
        UserRole.DRIVER,
      ],
      'Access denied',
    );
    return this.ordersService.findOne(id);
  }

  @Put(':id/status')
  async updateStatus(
    @Param('id') id: string,
    @Body('status') status: OrderStatus,
    @Request() req: any,
  ) {
    const user = await this.getRequestUser(req);
    this.ensureRole(
      user.role,
      [
        UserRole.ADMIN,
        UserRole.MANAGER,
        UserRole.CASHIER,
        UserRole.WAITER,
        UserRole.KITCHEN,
        UserRole.DRIVER,
      ],
      'Access denied',
    );
    if (user.role === UserRole.DRIVER) {
      if (
        status !== OrderStatus.ON_DELIVERY &&
        status !== OrderStatus.DELIVERED
      ) {
        throw new ForbiddenException(
          'Driver can only update status to ON_DELIVERY or DELIVERED',
        );
      }
      const order = await this.ordersService.findOne(id);
      if (order.driverId !== user.id) {
        throw new ForbiddenException('Driver can only update their own orders');
      }
    }
    return this.ordersService.updateStatus(id, status);
  }

  @Post(':id/coupon')
  async applyCoupon(
    @Param('id') id: string,
    @Body('code') code: string,
    @Request() req: any,
  ) {
    const user = await this.getRequestUser(req);
    this.ensureRole(
      user.role,
      [UserRole.ADMIN, UserRole.MANAGER, UserRole.CASHIER, UserRole.WAITER],
      'Only front-of-house roles can apply coupons',
    );
    return this.ordersService.applyCoupon(id, code);
  }

  @Post(':id/redeem-points')
  async redeemPoints(
    @Param('id') id: string,
    @Body('points') points: number,
    @Request() req: any,
  ) {
    const user = await this.getRequestUser(req);
    this.ensureRole(
      user.role,
      [UserRole.ADMIN, UserRole.MANAGER, UserRole.CASHIER, UserRole.WAITER],
      'Only front-of-house roles can redeem points',
    );
    return this.ordersService.redeemPoints(id, points);
  }

  @Post(':id/pay')
  async payOrder(
    @Param('id') id: string,
    @Body('paymentMethod') paymentMethod: PaymentMethod,
    @Request() req: any,
  ) {
    const user = await this.getRequestUser(req);
    this.ensureRole(
      user.role,
      [UserRole.ADMIN, UserRole.MANAGER, UserRole.CASHIER, UserRole.WAITER],
      'Only front-of-house roles can close and pay orders',
    );
    if (!paymentMethod) {
      throw new BadRequestException('Payment method is required');
    }
    return this.ordersService.payOrder(id, paymentMethod);
  }

  @Post(':id/fire')
  async fireCourse(
    @Param('id') id: string,
    @Body('course') course: string,
    @Request() req: any,
  ) {
    const user = await this.getRequestUser(req);
    this.ensureRole(
      user.role,
      [UserRole.ADMIN, UserRole.MANAGER, UserRole.WAITER, UserRole.KITCHEN],
      'Only waiter, kitchen, manager, and admin can fire courses',
    );
    return this.ordersService.fireCourse(id, course);
  }

  @Post(':id/assign-driver')
  async assignDriver(
    @Param('id') id: string,
    @Body('driverId') driverId: string,
    @Request() req: any,
  ) {
    const user = await this.getRequestUser(req);
    this.ensureRole(
      user.role,
      [UserRole.ADMIN, UserRole.MANAGER],
      'Only managers/admins can assign drivers',
    );
    return this.ordersService.assignDriver(id, driverId);
  }

  @Get('driver/:driverId')
  async getDriverOrders(
    @Param('driverId') driverId: string,
    @Request() req: any,
  ) {
    const user = await this.getRequestUser(req);
    if (user.role === UserRole.DRIVER && user.id !== driverId) {
      throw new ForbiddenException(
        'Driver can only access their own deliveries',
      );
    }
    this.ensureRole(
      user.role,
      [UserRole.ADMIN, UserRole.MANAGER, UserRole.DRIVER],
      'Only driver, manager, and admin can access driver deliveries',
    );
    return this.ordersService.findByDriver(driverId);
  }

  @Post(':id/refund')
  async requestRefund(
    @Param('id') id: string,
    @Body('amount') amount: number,
    @Body('reason') reason: string,
    @Request() req: any,
  ) {
    const user = await this.getRequestUser(req);
    this.ensureRole(
      user.role,
      [UserRole.ADMIN, UserRole.MANAGER, UserRole.CASHIER],
      'Only cashier, manager, and admin can request refunds',
    );
    return this.ordersService.requestRefund(id, amount, reason);
  }

  @Post('refunds/:id/approve')
  async approveRefund(@Param('id') id: string, @Request() req: any) {
    const user = await this.getRequestUser(req);
    this.ensureRole(
      user.role,
      [UserRole.MANAGER, UserRole.ADMIN],
      'Only managers/admins can approve refunds',
    );
    return this.ordersService.approveRefund(id, user.id);
  }

  @Post('refunds/:id/reject')
  async rejectRefund(@Param('id') id: string, @Request() req: any) {
    const user = await this.getRequestUser(req);
    this.ensureRole(
      user.role,
      [UserRole.MANAGER, UserRole.ADMIN],
      'Only managers/admins can reject refunds',
    );
    return this.ordersService.rejectRefund(id, user.id);
  }

  @Get('refunds/pending')
  async getPendingRefunds(@Request() req: any) {
    const user = await this.getRequestUser(req);
    this.ensureRole(
      user.role,
      [UserRole.MANAGER, UserRole.ADMIN],
      'Only managers/admins can view pending refunds',
    );
    return this.ordersService.findPendingRefunds();
  }

  @Post(':id/void')
  async voidOrder(
    @Param('id') id: string,
    @Body('reason') reason: string,
    @Body('returnStock') returnStock: boolean,
    @Request() req: any,
  ) {
    const user = await this.getRequestUser(req);
    this.ensureRole(
      user.role,
      [UserRole.ADMIN, UserRole.MANAGER],
      'Only managers/admins can void orders',
    );
    return this.ordersService.voidOrder(id, user.id, reason, returnStock);
  }
}
