import {
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
} from 'class-validator';
import { TransactionType } from '../cash-transaction.entity';

export class CreateCashTransactionDto {
  @IsString()
  @IsOptional()
  shiftId?: string;

  @IsEnum(TransactionType)
  type: TransactionType;

  @IsNumber()
  amount: number;

  @IsString()
  @IsNotEmpty()
  reason: string;
}
