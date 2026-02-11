import { Controller, Post, Body, Get, Param, UseGuards, Request } from '@nestjs/common';
import { ShiftsService } from './shifts.service';
import { CreateShiftDto } from './dto/create-shift.dto';
import { CloseShiftDto } from './dto/close-shift.dto';
import { CreateCashTransactionDto } from './dto/create-cash-transaction.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('shifts')
@UseGuards(JwtAuthGuard)
export class ShiftsController {
  constructor(private readonly shiftsService: ShiftsService) {}

  @Post('open')
  async openShift(@Request() req: any, @Body() createShiftDto: CreateShiftDto) {
    return this.shiftsService.openShift(req.user, createShiftDto);
  }

  @Post('close')
  async closeShift(@Request() req: any, @Body() closeShiftDto: CloseShiftDto) {
    return this.shiftsService.closeShift(req.user.id, closeShiftDto);
  }

  @Post('transaction')
  async addCashTransaction(@Request() req: any, @Body() dto: CreateCashTransactionDto) {
    return this.shiftsService.addCashTransaction(req.user.id, dto);
  }

  @Get('current')
  async getCurrentShift(@Request() req: any) {
    return this.shiftsService.getOpenShift(req.user.id);
  }

  @Get(':id')
  async getShift(@Param('id') id: string) {
    return this.shiftsService.getShiftDetails(id);
  }
}
