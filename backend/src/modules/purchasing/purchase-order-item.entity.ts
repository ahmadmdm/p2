import { Entity, Column, PrimaryGeneratedColumn, ManyToOne } from 'typeorm';
import { PurchaseOrder } from './purchase-order.entity';
import { Ingredient } from '../inventory/ingredient.entity';

@Entity('purchase_order_items')
export class PurchaseOrderItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => PurchaseOrder, (po) => po.items, { onDelete: 'CASCADE' })
  purchaseOrder: PurchaseOrder;

  @ManyToOne(() => Ingredient, { eager: true })
  ingredient: Ingredient;

  @Column()
  ingredientId: string;

  @Column('decimal', { precision: 10, scale: 3 })
  quantity: number;

  @Column('decimal', { precision: 10, scale: 2 })
  unitPrice: number;

  @Column('decimal', { precision: 10, scale: 2 })
  totalPrice: number;
}
