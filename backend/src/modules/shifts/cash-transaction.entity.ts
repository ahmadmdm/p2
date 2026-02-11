import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  CreateDateColumn,
} from 'typeorm';
import { Shift } from './shift.entity';

export enum TransactionType {
  IN = 'IN', // Pay In
  OUT = 'OUT', // Pay Out
}

@Entity('cash_transactions')
export class CashTransaction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Shift, (shift) => shift.cashTransactions, {
    onDelete: 'CASCADE',
  })
  shift: Shift;

  @Column({
    type: 'enum',
    enum: TransactionType,
  })
  type: TransactionType;

  @Column('decimal', { precision: 10, scale: 2 })
  amount: number;

  @Column()
  reason: string;

  @CreateDateColumn()
  createdAt: Date;
}
