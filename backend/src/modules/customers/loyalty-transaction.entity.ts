import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Customer } from './customer.entity';

export enum LoyaltyTransactionType {
  EARN = 'EARN',
  REDEEM = 'REDEEM',
  ADJUSTMENT = 'ADJUSTMENT',
}

@Entity('loyalty_transactions')
export class LoyaltyTransaction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  customerId: string;

  @ManyToOne(() => Customer, (customer) => customer.loyaltyTransactions)
  @JoinColumn({ name: 'customerId' })
  customer: Customer;

  @Column()
  points: number; // Positive for EARN, Negative for REDEEM

  @Column({
    type: 'simple-enum',
    enum: LoyaltyTransactionType,
    default: LoyaltyTransactionType.EARN,
  })
  type: LoyaltyTransactionType;

  @Column({ nullable: true })
  orderId: string;

  @Column({ nullable: true })
  description: string;

  @CreateDateColumn()
  createdAt: Date;
}
