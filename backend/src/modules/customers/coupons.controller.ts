import { Controller, Get, Post, Body, Query } from '@nestjs/common';
import { CouponsService } from './coupons.service';
import { Coupon } from './coupon.entity';

@Controller('coupons')
export class CouponsController {
  constructor(private readonly couponsService: CouponsService) {}

  @Post()
  create(@Body() data: Partial<Coupon>) {
    return this.couponsService.create(data);
  }

  @Get()
  findAll() {
    return this.couponsService.findAll();
  }

  @Get('validate')
  validate(@Query('code') code: string, @Query('amount') amount: number) {
    return this.couponsService.validateCoupon(code, amount);
  }
}
