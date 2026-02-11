import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CatalogService } from './catalog.service';
import { CatalogController } from './catalog.controller';
import { Category } from './category.entity';
import { Product } from './product.entity';
import { ModifierGroup } from './modifier-group.entity';
import { ModifierItem } from './modifier-item.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Category, Product, ModifierGroup, ModifierItem]),
  ],
  providers: [CatalogService],
  controllers: [CatalogController],
  exports: [CatalogService],
})
export class CatalogModule {}
