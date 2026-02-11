import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Station } from './station.entity';
import { OrdersService } from '../orders/orders.service';
import { OrderStatus } from '../orders/order.entity';

@Injectable()
export class KitchenService {
  constructor(
    @InjectRepository(Station)
    private stationsRepository: Repository<Station>,
    private ordersService: OrdersService,
  ) {}

  async findAllStations() {
    return this.stationsRepository.find();
  }

  async createStation(data: Partial<Station>) {
    const station = this.stationsRepository.create(data);
    return this.stationsRepository.save(station);
  }

  async getKdsOrders(stationId?: string, course?: string) {
    const orders = await this.ordersService.findActiveOrders();

    // Filter items based on station and course
    return orders
      .map((order) => {
        let filteredItems = order.items;

        if (stationId) {
          filteredItems = filteredItems.filter(
            (item) => item.product.station?.id === stationId,
          );
        }

        if (course) {
          filteredItems = filteredItems.filter(
            (item) => item.product.course === course,
          );
        }

        if (filteredItems.length === 0) return null;

        return {
          ...order,
          items: filteredItems,
        };
      })
      .filter((order) => order !== null);
  }

  async updateItemStatus(itemId: string, status: string) {
    return this.ordersService.updateOrderItemStatus(itemId, status);
  }

  async bumpOrder(orderId: string) {
    const order = await this.ordersService.findOne(orderId);
    if (!order) throw new NotFoundException('Order not found');

    // Mark all non-final items as READY
    const promises = order.items
      .filter((item) => ['PENDING', 'PREPARING'].includes(item.status))
      .map((item) =>
        this.ordersService.updateOrderItemStatus(item.id, 'READY'),
      );

    await Promise.all(promises);

    return this.ordersService.updateStatus(orderId, OrderStatus.READY);
  }
}
