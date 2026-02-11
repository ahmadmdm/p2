import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from './user.entity';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async findOneByEmail(email: string): Promise<User | null> {
    return this.usersRepository.findOne({
      where: { email },
      select: ['id', 'email', 'passwordHash', 'name', 'role', 'isActive'], // Explicitly select passwordHash
    });
  }

  async findOneById(id: string): Promise<User | null> {
    return this.usersRepository.findOneBy({ id });
  }

  async create(userData: Partial<User>): Promise<User> {
    const user = this.usersRepository.create(userData);
    return this.usersRepository.save(user);
  }

  async findAll(): Promise<User[]> {
    return this.usersRepository.find();
  }

  async update(id: string, updateData: Partial<User>): Promise<User> {
    const user = await this.findOneById(id);
    if (!user) throw new NotFoundException('User not found');

    if (updateData.passwordHash) {
      // Hash it if it's being updated directly (usually service caller hashes it, but let's be safe if we move logic here)
      // Actually Auth service does hashing. Let's assume caller handles hashing or we do it here.
      // For simplicity, let's assume the controller passes already hashed password or we handle it in controller.
      // But better: handle it here if passed as plain text?
      // Let's keep it simple: updateData contains what to save.
    }

    Object.assign(user, updateData);
    return this.usersRepository.save(user);
  }

  async remove(id: string): Promise<void> {
    await this.usersRepository.delete(id);
  }
}
