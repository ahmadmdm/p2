import { Entity, Column, PrimaryGeneratedColumn, OneToMany } from 'typeorm';
import { Product } from '../catalog/product.entity';

@Entity('stations')
export class Station {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string; // e.g., "Grill", "Bar", "Dessert"

  @Column({ nullable: true })
  printerName: string; // Friendly name

  @Column({ nullable: true })
  printerIp: string; // Network IP

  @Column({ nullable: true, default: 9100 })
  printerPort: number;

  @OneToMany(() => Product, (product) => product.station)
  products: Product[];
}
