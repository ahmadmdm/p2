import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CustomersService } from './customers.service';
import { CustomersController } from './customers.controller';
import { Customer } from './customer.entity';
import { LoyaltyTransaction } from './loyalty-transaction.entity';
import { Coupon } from './coupon.entity';
import { CouponsService } from './coupons.service';
import { CouponsController } from './coupons.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Customer, LoyaltyTransaction, Coupon])],
  controllers: [CustomersController, CouponsController],
  providers: [CustomersService, CouponsService],
  exports: [CustomersService, CouponsService],
})
export class CustomersModule {}
