import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Put,
  Delete,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { PurchasingService } from './purchasing.service';
import { PurchaseOrder, PurchaseOrderStatus } from './purchase-order.entity';

@Controller('purchasing')
@UseGuards(AuthGuard('jwt'))
export class PurchasingController {
  constructor(private readonly purchasingService: PurchasingService) {}

  @Post('orders')
  create(@Body() body: Partial<PurchaseOrder>) {
    return this.purchasingService.create(body);
  }

  @Get('orders')
  findAll() {
    return this.purchasingService.findAll();
  }

  @Get('orders/:id')
  findOne(@Param('id') id: string) {
    return this.purchasingService.findOne(id);
  }

  @Post('orders/:id/items')
  addItem(@Param('id') id: string, @Body() body: any) {
    return this.purchasingService.addItem(id, body);
  }

  @Delete('items/:itemId')
  removeItem(@Param('itemId') itemId: string) {
    return this.purchasingService.removeItem(itemId);
  }

  @Put('orders/:id/status')
  updateStatus(
    @Param('id') id: string,
    @Body('status') status: PurchaseOrderStatus,
  ) {
    return this.purchasingService.updateStatus(id, status);
  }
}
