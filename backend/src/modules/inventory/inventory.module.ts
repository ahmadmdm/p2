import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { InventoryService } from './inventory.service';
import { InventoryController } from './inventory.controller';
import { Ingredient } from './ingredient.entity';
import { InventoryItem } from './inventory-item.entity';
import { RecipeItem } from './recipe-item.entity';
import { Product } from '../catalog/product.entity';
import { ModifierItem } from '../catalog/modifier-item.entity';
import { Warehouse } from './warehouse.entity';
import { WarehouseController } from './warehouse.controller';
import { InventoryLog } from './inventory-log.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Ingredient,
      InventoryItem,
      RecipeItem,
      Product,
      ModifierItem,
      Warehouse,
      InventoryLog,
    ]),
  ],
  controllers: [InventoryController, WarehouseController],
  providers: [InventoryService],
  exports: [InventoryService],
})
export class InventoryModule {}
