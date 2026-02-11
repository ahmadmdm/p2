import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  Put,
  UseGuards,
  Request,
  ForbiddenException,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { User, UserRole } from './user.entity';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import * as bcrypt from 'bcrypt';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  async findAll(@Request() req: any) {
    this.checkAdmin(req.user);
    return this.usersService.findAll();
  }

  @Post()
  async create(@Request() req: any, @Body() body: Partial<User>) {
    this.checkAdmin(req.user);
    // Hash password if provided
    if (body.passwordHash) {
      body.passwordHash = await bcrypt.hash(body.passwordHash, 10);
    }
    return this.usersService.create(body);
  }

  @Put(':id')
  async update(
    @Request() req: any,
    @Param('id') id: string,
    @Body() body: Partial<User>,
  ) {
    this.checkAdmin(req.user);
    if (body.passwordHash) {
      body.passwordHash = await bcrypt.hash(body.passwordHash, 10);
    }
    return this.usersService.update(id, body);
  }

  @Delete(':id')
  async remove(@Request() req: any, @Param('id') id: string) {
    this.checkAdmin(req.user);
    return this.usersService.remove(id);
  }

  private checkAdmin(user: User) {
    if (user.role !== UserRole.ADMIN) {
      throw new ForbiddenException('Only admins can manage users');
    }
  }
}
