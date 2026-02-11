import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Param,
  Delete,
  UseGuards,
} from '@nestjs/common';
import { TablesService } from './tables.service';
import { AuthGuard } from '@nestjs/passport';

@Controller('tables')
export class TablesController {
  constructor(private readonly tablesService: TablesService) {}

  @UseGuards(AuthGuard('jwt'))
  @Post()
  create(@Body() body: any) {
    return this.tablesService.create(body);
  }

  @UseGuards(AuthGuard('jwt'))
  @Post('layout')
  updateLayout(@Body() tables: any[]) {
    return this.tablesService.updateLayout(tables);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get()
  findAll() {
    return this.tablesService.findAll();
  }

  @UseGuards(AuthGuard('jwt'))
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.tablesService.findOne(id);
  }

  @UseGuards(AuthGuard('jwt'))
  @Put(':id')
  update(@Param('id') id: string, @Body() body: any) {
    return this.tablesService.update(id, body);
  }

  // Public endpoint to validate QR code or get table info
  @Get('qr/:code')
  findByQr(@Param('code') code: string) {
    return this.tablesService.findByQrCode(code);
  }

  @UseGuards(AuthGuard('jwt'))
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.tablesService.remove(id);
  }
}
