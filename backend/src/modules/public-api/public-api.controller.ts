import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  BadRequestException,
  Headers,
} from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';
import { PublicApiService } from './public-api.service';
import { CaptchaService } from './captcha.service';

@Controller('public-api')
@UseGuards(ThrottlerGuard)
export class PublicApiController {
  constructor(
    private readonly publicApiService: PublicApiService,
    private readonly captchaService: CaptchaService,
  ) {}

  @Get('captcha')
  getCaptcha() {
    return this.captchaService.generateCaptcha();
  }

  @Get('menu')
  getMenu(@Query('t') token: string) {
    return this.publicApiService.getMenu(token);
  }

  @Get('active-order')
  getActiveOrder(@Query('t') token: string) {
    return this.publicApiService.getActiveOrder(token);
  }

  @Post('orders')
  async createOrder(
    @Body() body: any,
    @Headers('x-captcha-id') captchaId?: string,
    @Headers('x-captcha-answer') captchaAnswer?: string,
  ) {
    // Lightweight captcha: In a real scenario, we would check if the request is suspicious
    // (e.g., high rate from IP) and ONLY then require captcha.
    // Here, we provide the mechanism. If the client sends captcha headers, we validate them.
    // If strict mode was enabled, we would throw if missing.

    if (captchaId && captchaAnswer) {
      const isValid = this.captchaService.validateCaptcha(
        captchaId,
        captchaAnswer,
      );
      if (!isValid) {
        throw new BadRequestException('Invalid captcha');
      }
    }

    const { token, ...orderData } = body;
    return this.publicApiService.createOrder(token, orderData);
  }

  @Get('orders/:id')
  getOrder(@Param('id') id: string, @Query('t') token: string) {
    return this.publicApiService.getOrder(token, id);
  }

  @Post('orders/:id/add-items')
  addItems(
    @Param('id') id: string,
    @Query('t') token: string,
    @Body() body: any,
  ) {
    return this.publicApiService.addItemsToOrder(token, id, body.items);
  }

  @Post('request-bill')
  requestBill(@Body() body: { token: string }) {
    return this.publicApiService.requestBill(body.token);
  }
}
