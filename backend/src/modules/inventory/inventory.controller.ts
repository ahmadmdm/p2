import { Controller, Get, Post, Body, Param, Query } from '@nestjs/common';
import { InventoryService } from './inventory.service';

@Controller('inventory')
export class InventoryController {
  constructor(private readonly inventoryService: InventoryService) {}

  @Post('ingredients')
  createIngredient(@Body() body: { name: string; unit: string }) {
    return this.inventoryService.createIngredient(body.name, body.unit);
  }

  @Get('ingredients')
  getIngredients() {
    return this.inventoryService.findAllIngredients();
  }

  @Post('stock/:ingredientId')
  updateStock(
    @Param('ingredientId') ingredientId: string,
    @Body('change') change: number,
    @Body('warehouseId') warehouseId?: string,
    @Body('reason') reason?: string,
    @Body('notes') notes?: string,
  ) {
    return this.inventoryService.updateStock(
      ingredientId,
      change,
      undefined,
      warehouseId,
      reason,
      undefined,
      notes,
    );
  }

  @Post('recipes')
  addRecipeItem(
    @Body() body: { productId: string; ingredientId: string; quantity: number },
  ) {
    return this.inventoryService.addRecipeItem(
      body.productId,
      body.ingredientId,
      body.quantity,
    );
  }

  @Post('recipes/modifier')
  addModifierRecipeItem(
    @Body()
    body: {
      modifierId: string;
      ingredientId: string;
      quantity: number;
    },
  ) {
    return this.inventoryService.addModifierRecipeItem(
      body.modifierId,
      body.ingredientId,
      body.quantity,
    );
  }

  @Get('recipes/all')
  getAllRecipes() {
    return this.inventoryService.getAllRecipes();
  }

  @Get('recipes/:productId')
  getProductRecipe(@Param('productId') productId: string) {
    return this.inventoryService.getProductRecipe(productId);
  }

  @Get('recipes/modifier/:modifierId')
  getModifierRecipe(@Param('modifierId') modifierId: string) {
    return this.inventoryService.getModifierRecipe(modifierId);
  }

  @Get('logs')
  getInventoryLogs(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.inventoryService.getInventoryLogs(
      startDate ? new Date(startDate) : undefined,
      endDate ? new Date(endDate) : undefined,
    );
  }
}
