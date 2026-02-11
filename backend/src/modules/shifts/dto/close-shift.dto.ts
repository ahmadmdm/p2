import { IsNumber, IsOptional, IsString } from 'class-validator';

export class CloseShiftDto {
  @IsString()
  @IsOptional()
  shiftId?: string;

  @IsNumber()
  endingCash: number;

  @IsString()
  @IsOptional()
  notes?: string;
}
