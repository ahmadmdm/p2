import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { LoyaltyTransaction } from './loyalty-transaction.entity';

@Entity('customers')
export class Customer {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ unique: true })
  phoneNumber: string;

  @Column({ nullable: true })
  email: string;

  @Column({ default: 0 })
  loyaltyPoints: number;

  @Column({ default: 'BRONZE' })
  tier: string; // BRONZE, SILVER, GOLD, PLATINUM

  @OneToMany(() => LoyaltyTransaction, (transaction) => transaction.customer)
  loyaltyTransactions: LoyaltyTransaction[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
