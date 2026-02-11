import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Category } from './category.entity';
import { Product } from './product.entity';

@Injectable()
export class CatalogService {
  constructor(
    @InjectRepository(Category)
    private categoryRepository: Repository<Category>,
    @InjectRepository(Product)
    private productRepository: Repository<Product>,
  ) {}

  // Categories
  async findAllCategories(): Promise<Category[]> {
    return this.categoryRepository.find({
      relations: ['products', 'products.modifierGroups', 'products.modifierGroups.items'],
      order: { sortOrder: 'ASC' },
    });
  }

  async findCategoryById(id: string): Promise<Category> {
    const category = await this.categoryRepository.findOne({
      where: { id },
      relations: ['products', 'products.modifierGroups', 'products.modifierGroups.items'],
    });
    if (!category) {
      throw new NotFoundException(`Category with ID ${id} not found`);
    }
    return category;
  }

  async createCategory(data: Partial<Category>): Promise<Category> {
    const category = this.categoryRepository.create(data);
    return this.categoryRepository.save(category);
  }

  async updateCategory(id: string, data: Partial<Category>): Promise<Category> {
    await this.categoryRepository.update(id, data);
    return this.findCategoryById(id);
  }

  async deleteCategory(id: string): Promise<void> {
    const result = await this.categoryRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Category with ID ${id} not found`);
    }
  }

  // Products
  async findAllProducts(): Promise<Product[]> {
    return this.productRepository.find({
      relations: ['category', 'modifierGroups', 'modifierGroups.items'],
      order: { name: 'ASC' },
    });
  }

  async findProductById(id: string): Promise<Product> {
    const product = await this.productRepository.findOne({
      where: { id },
      relations: ['category', 'modifierGroups', 'modifierGroups.items'],
    });
    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }
    return product;
  }

  async createProduct(categoryId: string, data: Partial<Product>): Promise<Product> {
    const category = await this.findCategoryById(categoryId);
    const product = this.productRepository.create({ ...data, category });
    return this.productRepository.save(product);
  }

  async updateProduct(id: string, data: Partial<Product>): Promise<Product> {
    await this.productRepository.update(id, data);
    return this.findProductById(id);
  }

  async deleteProduct(id: string): Promise<void> {
    const result = await this.productRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }
  }
}
