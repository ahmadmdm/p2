import { Controller, Get, Post, Body, Param, Put, Delete } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Warehouse } from './warehouse.entity';

@Controller('inventory/warehouses')
export class WarehouseController {
  constructor(
    @InjectRepository(Warehouse)
    private warehousesRepo: Repository<Warehouse>,
  ) {}

  @Get()
  async getAll() {
    return this.warehousesRepo.find();
  }

  @Post()
  async create(@Body() body: { name: string; address?: string; isMain?: boolean }) {
    const warehouse = this.warehousesRepo.create(body);
    return this.warehousesRepo.save(warehouse);
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() body: { name?: string; address?: string; isMain?: boolean }) {
    await this.warehousesRepo.update(id, body);
    return this.warehousesRepo.findOneBy({ id });
  }

  @Delete(':id')
  async delete(@Param('id') id: string) {
    return this.warehousesRepo.delete(id);
  }
}
