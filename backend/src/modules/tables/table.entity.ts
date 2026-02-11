import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
} from 'typeorm';

export enum TableShape {
  RECTANGLE = 'rectangle',
  CIRCLE = 'circle',
}

export enum TableStatus {
  FREE = 'free',
  OCCUPIED = 'occupied',
  SERVED = 'served',
  BILLED = 'billed',
  RESERVED = 'reserved',
}

@Entity('tables')
export class Table {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  tableNumber: string;

  @Column({ nullable: true })
  section: string; // e.g., "Main Hall", "Patio"

  @Column({ default: 4 })
  capacity: number;

  @Column({ generated: 'uuid' })
  qrCode: string; // Unique token for the QR URL

  // Layout fields
  @Column({ type: 'float', default: 0 })
  x: number;

  @Column({ type: 'float', default: 0 })
  y: number;

  @Column({ type: 'float', default: 100 })
  width: number;

  @Column({ type: 'float', default: 100 })
  height: number;

  @Column({ type: 'enum', enum: TableShape, default: TableShape.RECTANGLE })
  shape: TableShape;

  @Column({ type: 'float', default: 0 })
  rotation: number;

  @Column({ type: 'enum', enum: TableStatus, default: TableStatus.FREE })
  status: TableStatus;

  @CreateDateColumn()
  createdAt: Date;
}
