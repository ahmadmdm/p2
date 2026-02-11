import { IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateShiftDto {
  @IsString()
  @IsOptional()
  id?: string;

  @IsString()
  @IsOptional()
  startTime?: string;

  @IsNumber()
  startingCash: number;

  @IsString()
  @IsOptional()
  deviceId?: string;
}
