import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { PurchaseOrder, PurchaseOrderStatus } from './purchase-order.entity';
import { PurchaseOrderItem } from './purchase-order-item.entity';
import { InventoryService } from '../inventory/inventory.service';

@Injectable()
export class PurchasingService {
  constructor(
    @InjectRepository(PurchaseOrder)
    private poRepository: Repository<PurchaseOrder>,
    @InjectRepository(PurchaseOrderItem)
    private poItemRepository: Repository<PurchaseOrderItem>,
    private inventoryService: InventoryService,
    private dataSource: DataSource,
  ) {}

  async create(data: Partial<PurchaseOrder>) {
    const po = this.poRepository.create({
      ...data,
      status: PurchaseOrderStatus.DRAFT,
    });
    return this.poRepository.save(po);
  }

  async findAll() {
    return this.poRepository.find({
      relations: ['items', 'items.ingredient', 'supplier'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string) {
    const po = await this.poRepository.findOne({
      where: { id },
      relations: ['items', 'items.ingredient', 'supplier'],
    });
    if (!po) throw new NotFoundException(`Purchase Order ${id} not found`);
    return po;
  }

  async addItem(poId: string, itemData: Partial<PurchaseOrderItem>) {
    const po = await this.findOne(poId);
    if (po.status !== PurchaseOrderStatus.DRAFT) {
      throw new BadRequestException('Cannot add items to non-draft PO');
    }

    // Calculate total price for item
    const totalPrice = (itemData.quantity || 0) * (itemData.unitPrice || 0);

    const item = this.poItemRepository.create({
      ...itemData,
      totalPrice,
      purchaseOrder: po,
    });
    await this.poItemRepository.save(item);

    // Update PO total
    await this.updatePOTotal(poId);
    return this.findOne(poId);
  }

  async removeItem(itemId: string) {
    const item = await this.poItemRepository.findOne({
      where: { id: itemId },
      relations: ['purchaseOrder'],
    });
    if (!item) throw new NotFoundException('Item not found');
    
    if (item.purchaseOrder.status !== PurchaseOrderStatus.DRAFT) {
      throw new BadRequestException('Cannot remove items from non-draft PO');
    }

    await this.poItemRepository.remove(item);
    await this.updatePOTotal(item.purchaseOrder.id);
  }

  async updateStatus(id: string, status: PurchaseOrderStatus) {
    const po = await this.findOne(id);
    
    if (po.status === status) return po;

    // Transactional status change
    return this.dataSource.transaction(async (manager) => {
      // If moving to RECEIVED, update inventory
      if (status === PurchaseOrderStatus.RECEIVED && po.status !== PurchaseOrderStatus.RECEIVED) {
        for (const item of po.items) {
          await this.inventoryService.updateStock(
            item.ingredientId, 
            item.quantity, 
            manager
          );
        }
      }

      // If moving FROM RECEIVED to something else (e.g. CANCELLED/DRAFT), revert inventory?
      // Usually we don't allow reverting RECEIVED POs easily without a return process.
      // But for simplicity, let's block it.
      if (po.status === PurchaseOrderStatus.RECEIVED && status !== PurchaseOrderStatus.RECEIVED) {
         throw new BadRequestException('Cannot revert a Received PO. Create a return instead.');
      }

      po.status = status;
      await manager.save(po);
      return po;
    });
  }

  private async updatePOTotal(poId: string) {
    const po = await this.poRepository.findOne({
      where: { id: poId },
      relations: ['items'],
    });
    if (po) {
      const total = po.items.reduce((sum, item) => sum + Number(item.totalPrice), 0);
      po.totalAmount = total;
      await this.poRepository.save(po);
    }
  }
}
