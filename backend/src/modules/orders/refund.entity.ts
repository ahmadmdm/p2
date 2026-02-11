import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn } from 'typeorm';
import { Order } from './order.entity';

@Entity('refunds')
export class Refund {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Order, (order) => order.refunds)
  order: Order;

  @Column('decimal', { precision: 10, scale: 2 })
  amount: number;

  @Column()
  reason: string;

  @Column({ nullable: true })
  managerId: string; // User ID of the manager who approved

  @Column({
    type: 'enum',
    enum: ['PENDING', 'APPROVED', 'REJECTED'],
    default: 'PENDING'
  })
  status: 'PENDING' | 'APPROVED' | 'REJECTED';

  @Column({ nullable: true })
  approvedAt: Date;

  @CreateDateColumn()
  createdAt: Date;
}
