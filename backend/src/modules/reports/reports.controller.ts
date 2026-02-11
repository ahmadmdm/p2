import {
  BadRequestException,
  Controller,
  Get,
  UseGuards,
  Query,
  Res,
  StreamableFile,
} from '@nestjs/common';
import { ReportsService } from './reports.service';
import { AuthGuard } from '@nestjs/passport';
import type { Response } from 'express';

@Controller('reports')
@UseGuards(AuthGuard('jwt'))
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  private parseDateRange(startDate?: string, endDate?: string) {
    const defaultStart = new Date(
      new Date().setDate(new Date().getDate() - 30),
    );
    const start = startDate ? new Date(startDate) : defaultStart;
    const end = endDate ? new Date(endDate) : new Date();

    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
      throw new BadRequestException('Invalid date range');
    }
    if (start > end) {
      throw new BadRequestException('startDate must be before endDate');
    }

    return { start, end };
  }

  @Get('export/excel')
  async exportExcel(
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
    @Res({ passthrough: true }) res: Response,
  ) {
    const { start, end } = this.parseDateRange(startDate, endDate);

    const buffer = await this.reportsService.generateSalesExcel(start, end);

    res.set({
      'Content-Type':
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'Content-Disposition': `attachment; filename="sales-report-${new Date().toISOString().split('T')[0]}.xlsx"`,
    });

    return new StreamableFile(buffer);
  }

  @Get('export/pdf')
  async exportPdf(
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
    @Res({ passthrough: true }) res: Response,
  ) {
    const { start, end } = this.parseDateRange(startDate, endDate);

    const buffer = await this.reportsService.generateSalesPdf(start, end);

    res.set({
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename="sales-report-${new Date().toISOString().split('T')[0]}.pdf"`,
    });

    return new StreamableFile(buffer);
  }

  @Get('daily-sales')
  async getDailySales() {
    return this.reportsService.getDailySales();
  }

  @Get('top-products')
  async getTopProducts() {
    return this.reportsService.getTopProducts();
  }

  @Get('low-stock')
  async getLowStockAlerts() {
    return this.reportsService.getLowStockAlerts();
  }

  @Get('sales-by-category')
  async getSalesByCategory() {
    return this.reportsService.getSalesByCategory();
  }
}
