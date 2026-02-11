import { Entity, Column, PrimaryGeneratedColumn, ManyToOne } from 'typeorm';
import { Product } from '../catalog/product.entity';
import { Ingredient } from './ingredient.entity';
import { ModifierItem } from '../catalog/modifier-item.entity';

@Entity('recipe_items')
export class RecipeItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Product, (product) => product.recipeItems, { nullable: true })
  product: Product | null;

  @ManyToOne(() => ModifierItem, (modifier) => modifier.recipeItems, { nullable: true })
  modifierItem: ModifierItem | null;

  @ManyToOne(() => Ingredient, (ingredient) => ingredient.recipeItems)
  ingredient: Ingredient;

  @Column('decimal', { precision: 10, scale: 3 })
  quantity: number;
}
