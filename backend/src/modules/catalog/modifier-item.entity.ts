import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, OneToMany } from 'typeorm';
import { ModifierGroup } from './modifier-group.entity';
import { RecipeItem } from '../inventory/recipe-item.entity';

@Entity('modifier_items')
export class ModifierItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'jsonb' })
  name: { en: string; ar: string };

  @Column('decimal', { precision: 10, scale: 2, default: 0 })
  price: number;

  @ManyToOne(() => ModifierGroup, (group) => group.items)
  group: ModifierGroup;

  @OneToMany(() => RecipeItem, (recipe) => recipe.modifierItem)
  recipeItems: RecipeItem[];
}
