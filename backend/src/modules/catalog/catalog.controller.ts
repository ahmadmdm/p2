import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { CatalogService } from './catalog.service';
import { AuthGuard } from '@nestjs/passport';

@Controller('catalog')
export class CatalogController {
  constructor(private readonly catalogService: CatalogService) {}

  // Public Categories (No Auth)
  @Get('public/categories')
  async getPublicCategories() {
    return this.catalogService.findAllCategories();
  }

  // Categories
  @Get('categories')
  @UseGuards(AuthGuard('jwt'))
  async getCategories() {
    return this.catalogService.findAllCategories();
  }

  @Get('categories/:id')
  @UseGuards(AuthGuard('jwt'))
  async getCategory(@Param('id') id: string) {
    return this.catalogService.findCategoryById(id);
  }

  @Post('categories')
  @UseGuards(AuthGuard('jwt'))
  async createCategory(@Body() body: any) {
    return this.catalogService.createCategory(body);
  }

  @Put('categories/:id')
  @UseGuards(AuthGuard('jwt'))
  async updateCategory(@Param('id') id: string, @Body() body: any) {
    return this.catalogService.updateCategory(id, body);
  }

  @Delete('categories/:id')
  @UseGuards(AuthGuard('jwt'))
  async deleteCategory(@Param('id') id: string) {
    return this.catalogService.deleteCategory(id);
  }

  // Public Products (No Auth)
  @Get('public/products')
  async getPublicProducts() {
    return this.catalogService.findAllProducts();
  }

  // Products
  @Get('products')
  @UseGuards(AuthGuard('jwt'))
  async getProducts() {
    return this.catalogService.findAllProducts();
  }

  @Get('products/:id')
  @UseGuards(AuthGuard('jwt'))
  async getProduct(@Param('id') id: string) {
    return this.catalogService.findProductById(id);
  }

  @Post('categories/:categoryId/products')
  @UseGuards(AuthGuard('jwt'))
  async createProduct(
    @Param('categoryId') categoryId: string,
    @Body() body: any,
  ) {
    return this.catalogService.createProduct(categoryId, body);
  }

  @Put('products/:id')
  @UseGuards(AuthGuard('jwt'))
  async updateProduct(@Param('id') id: string, @Body() body: any) {
    return this.catalogService.updateProduct(id, body);
  }

  @Delete('products/:id')
  @UseGuards(AuthGuard('jwt'))
  async deleteProduct(@Param('id') id: string) {
    return this.catalogService.deleteProduct(id);
  }
}
