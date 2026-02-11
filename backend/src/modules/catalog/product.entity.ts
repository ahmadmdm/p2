import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  OneToMany,
  ManyToMany,
  JoinTable,
  CreateDateColumn,
} from 'typeorm';
import { Category } from './category.entity';
import { RecipeItem } from '../inventory/recipe-item.entity';
import { ModifierGroup } from './modifier-group.entity';
import { Station } from '../kitchen/station.entity';

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'jsonb' })
  name: { en: string; ar: string };

  @Column('decimal', { precision: 10, scale: 2 })
  price: number;

  @Column({ default: true })
  isAvailable: boolean;

  @ManyToOne(() => Category, (category) => category.products)
  category: Category;

  @ManyToOne(() => Station, (station) => station.products, { nullable: true })
  station: Station;

  @Column({
    type: 'enum',
    enum: ['STARTER', 'MAIN', 'DESSERT', 'DRINK', 'OTHER'],
    default: 'OTHER',
  })
  course: 'STARTER' | 'MAIN' | 'DESSERT' | 'DRINK' | 'OTHER';

  @ManyToMany(() => ModifierGroup, (group) => group.products)
  @JoinTable()
  modifierGroups: ModifierGroup[];

  @OneToMany(() => RecipeItem, (recipe) => recipe.product)
  recipeItems: RecipeItem[];

  @CreateDateColumn()
  createdAt: Date;
}
