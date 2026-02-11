import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  Patch,
} from '@nestjs/common';
import { KitchenService } from './kitchen.service';
import { Station } from './station.entity';

@Controller('kitchen')
export class KitchenController {
  constructor(private readonly kitchenService: KitchenService) {}

  @Get('stations')
  async getStations() {
    return this.kitchenService.findAllStations();
  }

  @Post('stations')
  async createStation(@Body() data: Partial<Station>) {
    return this.kitchenService.createStation(data);
  }

  @Get('orders')
  async getKdsOrders(
    @Query('stationId') stationId?: string,
    @Query('course') course?: string,
  ) {
    return this.kitchenService.getKdsOrders(stationId, course);
  }

  @Post('orders/:id/bump')
  async bumpOrder(@Param('id') id: string) {
    return this.kitchenService.bumpOrder(id);
  }

  @Patch('items/:id/status')
  async updateItemStatus(
    @Param('id') id: string,
    @Body('status') status: string,
  ) {
    return this.kitchenService.updateItemStatus(id, status);
  }
}
