import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, OneToMany, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { User } from '../users/user.entity';
import { CashTransaction } from './cash-transaction.entity';

export enum ShiftStatus {
  OPEN = 'OPEN',
  CLOSED = 'CLOSED',
}

@Entity('shifts')
export class Shift {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User)
  user: User; // Who opened/owns the shift

  @Column({ nullable: true })
  deviceId: string;

  @Column({ type: 'timestamp' })
  startTime: Date;

  @Column({ type: 'timestamp', nullable: true })
  endTime: Date;

  @Column('decimal', { precision: 10, scale: 2 })
  startingCash: number;

  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  endingCash: number; // Actual cash counted

  // Calculated fields (stored for historical record on close)
  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  totalCashSales: number;

  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  totalCardSales: number;

  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  totalCashIn: number;

  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  totalCashOut: number;

  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  expectedCash: number; // startingCash + totalCashSales + totalCashIn - totalCashOut

  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  difference: number; // endingCash - expectedCash

  @Column({
    type: 'enum',
    enum: ShiftStatus,
    default: ShiftStatus.OPEN,
  })
  status: ShiftStatus;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @OneToMany(() => CashTransaction, (transaction) => transaction.shift)
  cashTransactions: CashTransaction[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
