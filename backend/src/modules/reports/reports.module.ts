import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReportsService } from './reports.service';
import { ReportsController } from './reports.controller';
import { Order } from '../orders/order.entity';
import { OrderItem } from '../orders/order-item.entity';
import { InventoryItem } from '../inventory/inventory-item.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Order, OrderItem, InventoryItem])],
  controllers: [ReportsController],
  providers: [ReportsService],
})
export class ReportsModule {}
