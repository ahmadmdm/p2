import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Table } from './table.entity';

@Injectable()
export class TablesService {
  constructor(
    @InjectRepository(Table)
    private tablesRepository: Repository<Table>,
  ) {}

  async create(data: Partial<Table>): Promise<Table> {
    const table = this.tablesRepository.create(data);
    return this.tablesRepository.save(table);
  }

  async findAll(): Promise<Table[]> {
    return this.tablesRepository.find({ order: { tableNumber: 'ASC' } });
  }

  async findOne(id: string): Promise<Table> {
    const table = await this.tablesRepository.findOneBy({ id });
    if (!table) {
      throw new NotFoundException(`Table with ID ${id} not found`);
    }
    return table;
  }

  async findByQrCode(qrCode: string): Promise<Table> {
    const table = await this.tablesRepository.findOneBy({ qrCode });
    if (!table) {
      throw new NotFoundException('Invalid QR Code');
    }
    return table;
  }

  async update(id: string, data: Partial<Table>): Promise<Table> {
    await this.tablesRepository.update(id, data);
    return this.findOne(id);
  }

  async updateLayout(tables: Partial<Table>[]): Promise<Table[]> {
    const savedTables: Table[] = [];
    for (const t of tables) {
      if (t.id) {
        // Only update layout fields to avoid accidental overwrites of other data if payload is messy
        // But for now, we trust the payload or just spread it.
        // Let's filter to layout fields + tableNumber/section
        const { x, y, width, height, shape, rotation, section, tableNumber } = t;
        await this.tablesRepository.update(t.id, { x, y, width, height, shape, rotation, section, tableNumber });
        savedTables.push(await this.findOne(t.id));
      }
    }
    return savedTables;
  }

  async remove(id: string): Promise<void> {
    await this.tablesRepository.delete(id);
  }
}
