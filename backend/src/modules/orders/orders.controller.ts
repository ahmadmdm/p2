import { Controller, Get, Post, Body, Param, Put, NotFoundException, Request, ForbiddenException, BadRequestException } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { OrderStatus, PaymentMethod } from './order.entity';
import { CreateOrderDto } from './dto/create-order.dto';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { UserRole } from '../users/user.entity';

@Controller('orders')
export class OrdersController {
  constructor(
    private readonly ordersService: OrdersService,
    private readonly jwtService: JwtService,
    private readonly usersService: UsersService,
  ) {}

  @Post()
  async createOrder(@Body() body: CreateOrderDto, @Request() req: any) {
    let userId = req.user?.id;
  
    // If no user in req (no Guard), try to decode header
    if (!userId && req.headers.authorization) {
      const token = req.headers.authorization.split(' ')[1];
      try {
        const decoded = this.jwtService.decode(token) as any;
        if (decoded && decoded.sub) {
          userId = decoded.sub;
        }
      } catch (e) {
        // Ignore invalid token
      }
    }

    return this.ordersService.createOrder(body, userId);
  }

  @Get()
  async getOrders() {
    return this.ordersService.findAll();
  }

  @Get(':id')
  async getOrder(@Param('id') id: string) {
    return this.ordersService.findOne(id);
  }

  @Put(':id/status')
  async updateStatus(
    @Param('id') id: string,
    @Body('status') status: OrderStatus,
  ) {
    return this.ordersService.updateStatus(id, status);
  }

  @Post(':id/coupon')
  async applyCoupon(
    @Param('id') id: string,
    @Body('code') code: string,
  ) {
    return this.ordersService.applyCoupon(id, code);
  }

  @Post(':id/redeem-points')
  async redeemPoints(
    @Param('id') id: string,
    @Body('points') points: number,
  ) {
    return this.ordersService.redeemPoints(id, points);
  }

  @Post(':id/pay')
  async payOrder(@Param('id') id: string, @Body('paymentMethod') paymentMethod: PaymentMethod) {
    if (!paymentMethod) {
      throw new BadRequestException('Payment method is required');
    }
    return this.ordersService.payOrder(id, paymentMethod);
  }

  @Post(':id/fire')
  async fireCourse(@Param('id') id: string, @Body('course') course: string) {
    return this.ordersService.fireCourse(id, course);
  }

  @Post(':id/assign-driver')
  async assignDriver(@Param('id') id: string, @Body('driverId') driverId: string) {
    return this.ordersService.assignDriver(id, driverId);
  }

  @Get('driver/:driverId')
  async getDriverOrders(@Param('driverId') driverId: string) {
    return this.ordersService.findByDriver(driverId);
  }

  @Post(':id/refund')
  async requestRefund(
    @Param('id') id: string,
    @Body('amount') amount: number,
    @Body('reason') reason: string,
  ) {
    return this.ordersService.requestRefund(id, amount, reason);
  }

  @Post('refunds/:id/approve')
  async approveRefund(
    @Param('id') id: string,
    @Request() req: any,
  ) {
    let userId = req.user?.id;
    if (!userId && req.headers.authorization) {
      const token = req.headers.authorization.split(' ')[1];
      try {
        const decoded = this.jwtService.decode(token) as any;
        if (decoded && decoded.sub) userId = decoded.sub;
      } catch (e) {}
    }

    if (!userId) {
      throw new ForbiddenException('User not authenticated');
    }
    const user = await this.usersService.findOneById(userId);
    if (!user || (user.role !== UserRole.MANAGER && user.role !== UserRole.ADMIN)) {
      throw new ForbiddenException('Only managers can approve refunds');
    }

    return this.ordersService.approveRefund(id, userId);
  }

  @Post('refunds/:id/reject')
  async rejectRefund(
    @Param('id') id: string,
    @Request() req: any,
  ) {
    let userId = req.user?.id;
    if (!userId && req.headers.authorization) {
      const token = req.headers.authorization.split(' ')[1];
      try {
        const decoded = this.jwtService.decode(token) as any;
        if (decoded && decoded.sub) userId = decoded.sub;
      } catch (e) {}
    }

    if (!userId) {
      throw new ForbiddenException('User not authenticated');
    }
    const user = await this.usersService.findOneById(userId);
    if (!user || (user.role !== UserRole.MANAGER && user.role !== UserRole.ADMIN)) {
      throw new ForbiddenException('Only managers can reject refunds');
    }

    return this.ordersService.rejectRefund(id, userId);
  }

  @Get('refunds/pending')
  async getPendingRefunds() {
    return this.ordersService.findPendingRefunds();
  }

  @Post(':id/void')
  async voidOrder(
    @Param('id') id: string,
    @Body('reason') reason: string,
    @Body('returnStock') returnStock: boolean,
    @Request() req: any,
  ) {
    let userId = req.user?.id;
    if (!userId && req.headers.authorization) {
      const token = req.headers.authorization.split(' ')[1];
      try {
        const decoded = this.jwtService.decode(token) as any;
        if (decoded && decoded.sub) userId = decoded.sub;
      } catch (e) {}
    }
    return this.ordersService.voidOrder(id, userId, reason, returnStock);
  }
}
