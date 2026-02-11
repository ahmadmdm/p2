import { Entity, Column, PrimaryGeneratedColumn, OneToMany } from 'typeorm';
import { InventoryItem } from './inventory-item.entity';
import { RecipeItem } from './recipe-item.entity';

@Entity('ingredients')
export class Ingredient {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column()
  unit: string; // kg, g, l, pcs

  @OneToMany(() => InventoryItem, (stock) => stock.ingredient)
  stock: InventoryItem[];

  @OneToMany(() => RecipeItem, (recipe) => recipe.ingredient)
  recipeItems: RecipeItem[];
}
