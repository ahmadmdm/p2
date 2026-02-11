import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, Unique } from 'typeorm';
import { Ingredient } from './ingredient.entity';
import { Warehouse } from './warehouse.entity';

@Entity('inventory_items')
@Unique(['ingredient', 'warehouse'])
export class InventoryItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Ingredient, (ingredient) => ingredient.stock)
  ingredient: Ingredient;

  @ManyToOne(() => Warehouse, (warehouse) => warehouse.items, { nullable: true })
  warehouse: Warehouse;

  @Column('decimal', { precision: 10, scale: 3, default: 0 })
  quantity: number;

  @Column('decimal', { precision: 10, scale: 3, default: 0 })
  minLevel: number;
}
