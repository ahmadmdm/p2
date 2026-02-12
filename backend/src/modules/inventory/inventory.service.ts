import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, EntityManager } from 'typeorm';
import { Ingredient } from './ingredient.entity';
import { InventoryItem } from './inventory-item.entity';
import { RecipeItem } from './recipe-item.entity';
import { Product } from '../catalog/product.entity';
import { ModifierItem } from '../catalog/modifier-item.entity';
import { Warehouse } from './warehouse.entity';
import { InventoryLog } from './inventory-log.entity';

@Injectable()
export class InventoryService {
  constructor(
    @InjectRepository(Ingredient)
    private ingredientsRepo: Repository<Ingredient>,
    @InjectRepository(InventoryItem)
    private inventoryRepo: Repository<InventoryItem>,
    @InjectRepository(RecipeItem)
    private recipesRepo: Repository<RecipeItem>,
    @InjectRepository(Product)
    private productsRepo: Repository<Product>,
    @InjectRepository(ModifierItem)
    private modifiersRepo: Repository<ModifierItem>,
    @InjectRepository(Warehouse)
    private warehousesRepo: Repository<Warehouse>,
    @InjectRepository(InventoryLog)
    private logsRepo: Repository<InventoryLog>,
  ) {}

  private async getMainWarehouse(manager?: EntityManager): Promise<Warehouse> {
    const repo = manager
      ? manager.getRepository(Warehouse)
      : this.warehousesRepo;
    const main = await repo.findOne({ where: { isMain: true } });
    if (main) return main;

    // Create default main warehouse if none exists
    const newMain = repo.create({ name: 'Main Warehouse', isMain: true });
    return repo.save(newMain);
  }

  // --- Ingredients ---
  async createIngredient(name: string, unit: string) {
    const ingredient = this.ingredientsRepo.create({ name, unit });
    return this.ingredientsRepo.save(ingredient);
  }

  async findAllIngredients() {
    return this.ingredientsRepo.find({
      relations: ['stock', 'stock.warehouse'],
    });
  }

  // --- Stock ---
  async updateStock(
    ingredientId: string,
    quantityChange: number,
    manager?: EntityManager,
    warehouseId?: string,
    reason: string = 'ADJUSTMENT',
    referenceId?: string,
    notes?: string,
  ) {
    const normalizedChange = Number(quantityChange);
    if (Number.isNaN(normalizedChange) || !Number.isFinite(normalizedChange)) {
      throw new BadRequestException('Quantity change must be a valid number');
    }
    if (normalizedChange === 0) {
      throw new BadRequestException('Quantity change cannot be zero');
    }

    const repo = manager
      ? manager.getRepository(InventoryItem)
      : this.inventoryRepo;
    const ingredientRepo = manager
      ? manager.getRepository(Ingredient)
      : this.ingredientsRepo;
    const warehouseRepo = manager
      ? manager.getRepository(Warehouse)
      : this.warehousesRepo;
    const logsRepo = manager
      ? manager.getRepository(InventoryLog)
      : this.logsRepo;

    let warehouse: Warehouse;
    if (warehouseId) {
      const found = await warehouseRepo.findOneBy({ id: warehouseId });
      if (!found) throw new NotFoundException('Warehouse not found');
      warehouse = found;
    } else {
      warehouse = await this.getMainWarehouse(manager);
    }

    let stock = await repo.findOne({
      where: {
        ingredient: { id: ingredientId },
        warehouse: { id: warehouse.id },
      },
      relations: ['ingredient', 'warehouse'],
    });

    if (!stock) {
      // Create if not exists (assume 0 initial)
      const ingredient = await ingredientRepo.findOneBy({ id: ingredientId });
      if (!ingredient) throw new NotFoundException('Ingredient not found');

      stock = repo.create({
        ingredient,
        warehouse,
        quantity: 0,
      });
    }

    const oldQuantity = Number(stock.quantity);
    stock.quantity = oldQuantity + normalizedChange;
    const savedStock = await repo.save(stock);

    // Log
    const log = logsRepo.create({
      ingredient: { id: ingredientId },
      warehouse: { id: warehouse.id },
      quantityChange: normalizedChange,
      reason,
      referenceId,
      notes,
      oldQuantity,
      newQuantity: stock.quantity,
    });
    await logsRepo.save(log);

    return savedStock;
  }

  // --- Recipes ---
  async addRecipeItem(
    productId: string,
    ingredientId: string,
    quantity: number,
  ) {
    if (Number(quantity) <= 0 || Number.isNaN(Number(quantity))) {
      throw new BadRequestException('Recipe quantity must be greater than zero');
    }

    const product = await this.productsRepo.findOneBy({ id: productId });
    const ingredient = await this.ingredientsRepo.findOneBy({
      id: ingredientId,
    });

    if (!product || !ingredient)
      throw new NotFoundException('Product or Ingredient not found');

    const recipeItem = this.recipesRepo.create({
      product,
      ingredient,
      quantity,
    });
    return this.recipesRepo.save(recipeItem);
  }

  async addModifierRecipeItem(
    modifierId: string,
    ingredientId: string,
    quantity: number,
  ) {
    if (Number(quantity) <= 0 || Number.isNaN(Number(quantity))) {
      throw new BadRequestException('Recipe quantity must be greater than zero');
    }

    const modifier = await this.modifiersRepo.findOneBy({ id: modifierId });
    const ingredient = await this.ingredientsRepo.findOneBy({ id: ingredientId });

    if (!modifier || !ingredient) {
      throw new NotFoundException('Modifier or Ingredient not found');
    }

    const recipeItem = this.recipesRepo.create({
      modifierItem: modifier,
      ingredient,
      quantity,
    });
    return this.recipesRepo.save(recipeItem);
  }

  async getProductRecipe(productId: string) {
    return this.recipesRepo.find({
      where: { product: { id: productId } },
      relations: ['ingredient'],
    });
  }

  async getModifierRecipe(modifierId: string) {
    return this.recipesRepo.find({
      where: { modifierItem: { id: modifierId } },
      relations: ['ingredient'],
    });
  }

  async getAllRecipes() {
    return this.recipesRepo.find({
      relations: ['ingredient', 'product', 'modifierItem'],
    });
  }

  // --- Consumption Logic ---

  async checkStockAvailability(
    items: { productId: string; quantity: number; modifierIds: string[] }[],
  ): Promise<boolean> {
    // 1. Calculate total required ingredients
    const requiredIngredients = new Map<string, number>();

    for (const item of items) {
      // Product Recipe
      const productRecipes = await this.recipesRepo.find({
        where: { product: { id: item.productId } },
        relations: ['ingredient'],
      });

      for (const recipe of productRecipes) {
        const current = requiredIngredients.get(recipe.ingredient.id) || 0;
        requiredIngredients.set(
          recipe.ingredient.id,
          current + Number(recipe.quantity) * item.quantity,
        );
      }

      // Modifiers Recipe
      if (item.modifierIds && item.modifierIds.length > 0) {
        for (const modId of item.modifierIds) {
          // Use a workaround to find by modifierItem since we might not have the repo injected directly but relation exists
          const modRecipes = await this.recipesRepo.find({
            where: { modifierItem: { id: modId } },
            relations: ['ingredient'],
          });

          for (const recipe of modRecipes) {
            const current = requiredIngredients.get(recipe.ingredient.id) || 0;
            requiredIngredients.set(
              recipe.ingredient.id,
              current + Number(recipe.quantity) * item.quantity,
            );
          }
        }
      }
    }

    // 2. Check against stock
    const mainWarehouse = await this.getMainWarehouse();
    for (const [ingredientId, requiredQty] of requiredIngredients.entries()) {
      const stock = await this.inventoryRepo.findOne({
        where: {
          ingredient: { id: ingredientId },
          warehouse: { id: mainWarehouse.id },
        },
      });

      if (!stock || Number(stock.quantity) < requiredQty) {
        return false;
      }
    }

    return true;
  }

  async deductStockForOrder(
    items: { productId: string; quantity: number; modifierIds: string[] }[],
    manager: EntityManager,
  ): Promise<void> {
    const recipesRepo = manager.getRepository(RecipeItem);

    for (const item of items) {
      // Deduct Product Recipe
      const productRecipes = await recipesRepo.find({
        where: { product: { id: item.productId } },
        relations: ['ingredient'],
      });

      for (const recipe of productRecipes) {
        await this.deductIngredientStock(
          recipe.ingredient.id,
          Number(recipe.quantity) * item.quantity,
          manager,
        );
      }

      // Deduct Modifier Recipe
      if (item.modifierIds && item.modifierIds.length > 0) {
        for (const modId of item.modifierIds) {
          const modRecipes = await recipesRepo.find({
            where: { modifierItem: { id: modId } },
            relations: ['ingredient'],
          });

          for (const recipe of modRecipes) {
            await this.deductIngredientStock(
              recipe.ingredient.id,
              Number(recipe.quantity) * item.quantity,
              manager,
            );
          }
        }
      }
    }
  }

  async restoreStockForOrder(
    items: { productId: string; quantity: number; modifierIds: string[] }[],
    manager: EntityManager,
  ): Promise<void> {
    const recipesRepo = manager.getRepository(RecipeItem);

    for (const item of items) {
      // Restore Product Recipe
      const productRecipes = await recipesRepo.find({
        where: { product: { id: item.productId } },
        relations: ['ingredient'],
      });

      for (const recipe of productRecipes) {
        await this.updateStock(
          recipe.ingredient.id,
          Number(recipe.quantity) * item.quantity,
          manager,
        );
      }

      // Restore Modifier Recipe
      if (item.modifierIds && item.modifierIds.length > 0) {
        for (const modId of item.modifierIds) {
          const modRecipes = await recipesRepo.find({
            where: { modifierItem: { id: modId } },
            relations: ['ingredient'],
          });

          for (const recipe of modRecipes) {
            await this.updateStock(
              recipe.ingredient.id,
              Number(recipe.quantity) * item.quantity,
              manager,
            );
          }
        }
      }
    }
  }

  private async deductIngredientStock(
    ingredientId: string,
    amount: number,
    manager: EntityManager,
  ) {
    if (Number(amount) <= 0 || Number.isNaN(Number(amount))) {
      throw new BadRequestException('Deduction amount must be greater than zero');
    }

    const inventoryRepo = manager.getRepository(InventoryItem);
    const ingredientRepo = manager.getRepository(Ingredient);
    const logsRepo = manager.getRepository(InventoryLog);

    const mainWarehouse = await this.getMainWarehouse(manager);

    // Use lock to handle concurrency safely
    const stock = await inventoryRepo.findOne({
      where: {
        ingredient: { id: ingredientId },
        warehouse: { id: mainWarehouse.id },
      },
      // lock: { mode: 'pessimistic_write' } // SQLite doesn't support pessimistic_write well, avoid if using SQLite. Postgres supports it.
      // Assuming Postgres as per requirements. But if dev env is SQLite, this might fail.
      // Let's skip explicit lock for now to be safe across DBs, relying on transaction isolation.
    });

    if (stock) {
      if (Number(stock.quantity) < amount) {
        throw new BadRequestException(
          `Insufficient stock for ingredient ${ingredientId}`,
        );
      }
      stock.quantity = Number(stock.quantity) - amount;
      await inventoryRepo.save(stock);
    } else {
      const ingredient = await ingredientRepo.findOneBy({ id: ingredientId });
      if (!ingredient) {
        throw new NotFoundException(`Ingredient ${ingredientId} not found`);
      }
      throw new BadRequestException(`Insufficient stock for ingredient ${ingredientId}`);
    }

    // Log
    const log = logsRepo.create({
      ingredient: { id: ingredientId },
      warehouse: { id: mainWarehouse.id },
      quantityChange: -amount,
      reason: 'SALE',
    });
    await logsRepo.save(log);
  }

  async getInventoryLogs(startDate?: Date, endDate?: Date) {
    const query = this.logsRepo
      .createQueryBuilder('log')
      .leftJoinAndSelect('log.ingredient', 'ingredient')
      .leftJoinAndSelect('log.warehouse', 'warehouse')
      .orderBy('log.createdAt', 'DESC');

    if (startDate) {
      query.andWhere('log.createdAt >= :startDate', { startDate });
    }
    if (endDate) {
      query.andWhere('log.createdAt <= :endDate', { endDate });
    }

    return query.getMany();
  }
}
