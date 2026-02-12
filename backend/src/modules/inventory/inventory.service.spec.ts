import { BadRequestException } from '@nestjs/common';
import { InventoryService } from './inventory.service';

describe('InventoryService', () => {
  const createService = () => {
    const ingredientsRepo = {};
    const inventoryRepo = {};
    const recipesRepo = {};
    const productsRepo = {};
    const modifiersRepo = {};
    const warehousesRepo = {};
    const logsRepo = {};

    return new InventoryService(
      ingredientsRepo as any,
      inventoryRepo as any,
      recipesRepo as any,
      productsRepo as any,
      modifiersRepo as any,
      warehousesRepo as any,
      logsRepo as any,
    );
  };

  it('rejects zero stock change', async () => {
    const service = createService();
    await expect(service.updateStock('ing-1', 0)).rejects.toThrow(
      BadRequestException,
    );
  });

  it('rejects invalid recipe quantity for product recipe', async () => {
    const service = createService();
    await expect(service.addRecipeItem('p-1', 'ing-1', 0)).rejects.toThrow(
      BadRequestException,
    );
  });

  it('rejects invalid recipe quantity for modifier recipe', async () => {
    const service = createService();
    await expect(
      service.addModifierRecipeItem('m-1', 'ing-1', -1),
    ).rejects.toThrow(BadRequestException);
  });
});
