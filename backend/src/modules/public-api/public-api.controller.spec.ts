import { BadRequestException } from '@nestjs/common';
import { PublicApiController } from './public-api.controller';

describe('PublicApiController', () => {
  const createController = () => {
    const publicApiService = { createOrder: jest.fn() };
    const captchaService = { validateCaptcha: jest.fn() };
    const controller = new PublicApiController(
      publicApiService as any,
      captchaService as any,
    );
    return { controller, publicApiService, captchaService };
  };

  afterEach(() => {
    delete process.env.PUBLIC_API_CAPTCHA_REQUIRED;
    jest.clearAllMocks();
  });

  it('rejects partial captcha headers', async () => {
    const { controller } = createController();
    await expect(
      controller.createOrder({ token: 't1', items: [{ productId: 'p1', quantity: 1 }] } as any, 'captcha-id'),
    ).rejects.toThrow(BadRequestException);
  });

  it('requires captcha in strict mode', async () => {
    process.env.PUBLIC_API_CAPTCHA_REQUIRED = 'true';
    const { controller } = createController();

    await expect(
      controller.createOrder({ token: 't1', items: [{ productId: 'p1', quantity: 1 }] } as any),
    ).rejects.toThrow(BadRequestException);
  });

  it('validates captcha when provided', async () => {
    const { controller, publicApiService, captchaService } = createController();
    captchaService.validateCaptcha.mockReturnValue(true);
    publicApiService.createOrder.mockResolvedValue({ id: 'order-1' });

    await controller.createOrder(
      { token: 't1', items: [{ productId: 'p1', quantity: 1 }] } as any,
      'captcha-id',
      '7',
    );

    expect(captchaService.validateCaptcha).toHaveBeenCalledWith(
      'captcha-id',
      '7',
    );
    expect(publicApiService.createOrder).toHaveBeenCalledWith('t1', {
      token: 't1',
      items: [{ productId: 'p1', quantity: 1 }],
    });
  });
});
