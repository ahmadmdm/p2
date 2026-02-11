import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  OneToMany,
  ManyToMany,
} from 'typeorm';
import { Product } from './product.entity';
import { ModifierItem } from './modifier-item.entity';

@Entity('modifier_groups')
export class ModifierGroup {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'jsonb' })
  name: { en: string; ar: string };

  @Column({ default: 'SINGLE' }) // SINGLE, MULTIPLE
  selectionType: string;

  @Column({ default: 0 })
  minSelection: number;

  @Column({ default: 1 })
  maxSelection: number;

  @OneToMany(() => ModifierItem, (item) => item.group, { cascade: true })
  items: ModifierItem[];

  @ManyToMany(() => Product, (product) => product.modifierGroups)
  products: Product[];
}
