import { Controller, Get, Post, Body, Param, Put, Query } from '@nestjs/common';
import { CustomersService } from './customers.service';

@Controller('customers')
export class CustomersController {
  constructor(private readonly customersService: CustomersService) {}

  @Get()
  findAll(@Query('search') search?: string) {
    return this.customersService.findAll(search);
  }

  @Get(':id/loyalty-history')
  getLoyaltyHistory(@Param('id') id: string) {
    return this.customersService.getLoyaltyHistory(id);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.customersService.findOne(id);
  }

  @Post()
  create(@Body() body: any) {
    return this.customersService.create(body);
  }

  @Post('login')
  async login(@Body() body: { phoneNumber: string }) {
    const customer = await this.customersService.findByPhone(body.phoneNumber);
    if (!customer) {
      // For MVP, we can just return null or throw
      // But maybe we want to auto-register?
      // Let's just return the customer if found, or null.
      // Better: standard REST.
      return { customer: null, message: 'Customer not found' };
    }
    return { customer };
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() body: any) {
    return this.customersService.update(id, body);
  }
}
