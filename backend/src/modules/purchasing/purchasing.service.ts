import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { PurchaseOrder, PurchaseOrderStatus } from './purchase-order.entity';
import { PurchaseOrderItem } from './purchase-order-item.entity';
import { InventoryService } from '../inventory/inventory.service';

const PURCHASE_ORDER_STATUS_TRANSITIONS: Readonly<
  Record<PurchaseOrderStatus, readonly PurchaseOrderStatus[]>
> = {
  [PurchaseOrderStatus.DRAFT]: [
    PurchaseOrderStatus.ORDERED,
    PurchaseOrderStatus.CANCELLED,
  ],
  [PurchaseOrderStatus.ORDERED]: [
    PurchaseOrderStatus.RECEIVED,
    PurchaseOrderStatus.CANCELLED,
  ],
  [PurchaseOrderStatus.RECEIVED]: [],
  [PurchaseOrderStatus.CANCELLED]: [],
};

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

  private parsePositiveAmount(value: unknown, fieldName: string): number {
    const parsed = Number(value);
    if (Number.isNaN(parsed) || parsed <= 0) {
      throw new BadRequestException(`${fieldName} must be greater than zero`);
    }
    return parsed;
  }

  private ensureStatusTransition(
    from: PurchaseOrderStatus,
    to: PurchaseOrderStatus,
  ): void {
    if (from === to) {
      return;
    }
    if (!PURCHASE_ORDER_STATUS_TRANSITIONS[from].includes(to)) {
      throw new BadRequestException(
        `Invalid purchase order status transition: ${from} -> ${to}`,
      );
    }
  }

  async create(data: Partial<PurchaseOrder>) {
    if (!data.supplierId || typeof data.supplierId !== 'string') {
      throw new BadRequestException('Supplier ID is required');
    }

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
    if (!itemData.ingredientId || typeof itemData.ingredientId !== 'string') {
      throw new BadRequestException('Ingredient ID is required');
    }

    const quantity = this.parsePositiveAmount(itemData.quantity, 'Quantity');
    const unitPrice = this.parsePositiveAmount(itemData.unitPrice, 'Unit price');

    // Calculate total price for item
    const totalPrice = quantity * unitPrice;

    const item = this.poItemRepository.create({
      ...itemData,
      quantity,
      unitPrice,
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

    if (!Object.values(PurchaseOrderStatus).includes(status)) {
      throw new BadRequestException(`Invalid purchase order status: ${status}`);
    }
    if (po.status === status) return po;
    this.ensureStatusTransition(po.status, status);

    // Transactional status change
    return this.dataSource.transaction(async (manager) => {
      // If moving to RECEIVED, update inventory
      if (
        status === PurchaseOrderStatus.RECEIVED &&
        po.status !== PurchaseOrderStatus.RECEIVED
      ) {
        if (!po.items || po.items.length === 0) {
          throw new BadRequestException(
            'Cannot receive purchase order without items',
          );
        }
        for (const item of po.items) {
          await this.inventoryService.updateStock(
            item.ingredientId,
            item.quantity,
            manager,
            undefined,
            'RESTOCK',
            po.id,
            `PO ${po.id} received`,
          );
        }
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
      const total = po.items.reduce(
        (sum, item) => sum + Number(item.totalPrice),
        0,
      );
      po.totalAmount = total;
      await this.poRepository.save(po);
    }
  }
}
