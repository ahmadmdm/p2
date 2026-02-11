import { Entity, Column, PrimaryGeneratedColumn, OneToMany } from 'typeorm';
import { InventoryItem } from './inventory-item.entity';

@Entity('warehouses')
export class Warehouse {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ nullable: true })
  address: string;

  @Column({ default: false })
  isMain: boolean;

  @OneToMany(() => InventoryItem, (item) => item.warehouse)
  items: InventoryItem[];
}
