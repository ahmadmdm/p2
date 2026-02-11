import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, CreateDateColumn } from 'typeorm';
import { Ingredient } from './ingredient.entity';
import { Warehouse } from './warehouse.entity';

@Entity('inventory_logs')
export class InventoryLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Ingredient)
  ingredient: Ingredient;

  @ManyToOne(() => Warehouse, { nullable: true })
  warehouse: Warehouse;

  @Column('decimal', { precision: 10, scale: 3 })
  quantityChange: number;

  @Column('decimal', { precision: 10, scale: 3, nullable: true })
  oldQuantity: number;

  @Column('decimal', { precision: 10, scale: 3, nullable: true })
  newQuantity: number;

  @Column()
  reason: string; // 'SALE', 'RESTOCK', 'WASTE', 'SPOILAGE', 'ADJUSTMENT'

  @Column({ nullable: true })
  notes: string;

  @Column({ nullable: true })
  referenceId: string; // Order ID, PO ID, etc.

  @CreateDateColumn()
  createdAt: Date;

  @Column({ nullable: true })
  userId: string;
}
