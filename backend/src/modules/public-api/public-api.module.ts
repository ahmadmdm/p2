import { Module } from '@nestjs/common';
import { PublicApiService } from './public-api.service';
import { CaptchaService } from './captcha.service';
import { PublicApiController } from './public-api.controller';
import { CatalogModule } from '../catalog/catalog.module';
import { OrdersModule } from '../orders/orders.module';
import { TablesModule } from '../tables/tables.module';

@Module({
  imports: [CatalogModule, OrdersModule, TablesModule],
  controllers: [PublicApiController],
  providers: [PublicApiService, CaptchaService],
})
export class PublicApiModule {}
