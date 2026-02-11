import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Shift, ShiftStatus } from './shift.entity';
import { CashTransaction, TransactionType } from './cash-transaction.entity';
import { CreateShiftDto } from './dto/create-shift.dto';
import { CloseShiftDto } from './dto/close-shift.dto';
import { CreateCashTransactionDto } from './dto/create-cash-transaction.dto';
import { User } from '../users/user.entity';
import { Order, PaymentMethod, PaymentStatus } from '../orders/order.entity';

@Injectable()
export class ShiftsService {
  constructor(
    @InjectRepository(Shift)
    private shiftsRepository: Repository<Shift>,
    @InjectRepository(CashTransaction)
    private cashTransactionsRepository: Repository<CashTransaction>,
    @InjectRepository(Order)
    private ordersRepository: Repository<Order>,
  ) {}

  async openShift(user: User, createShiftDto: CreateShiftDto): Promise<Shift> {
    // Idempotency Check: If ID is provided, check if it exists
    if (createShiftDto.id) {
      const existing = await this.shiftsRepository.findOne({
        where: { id: createShiftDto.id },
      });
      if (existing) return existing;
    }

    // Check if user already has an open shift (only if we are not syncing a specific historical shift)
    // If syncing a closed shift, we might allow it? But for now, openShift implies opening.
    // If we sync a CLOSED shift, we probably hit a different flow or sync all at once.
    // But usually we sync sequentially.

    const existingOpenShift = await this.shiftsRepository.findOne({
      where: {
        user: { id: user.id },
        status: ShiftStatus.OPEN,
      },
    });

    if (existingOpenShift) {
      // If we are syncing the same shift that is already open, return it
      if (createShiftDto.id && existingOpenShift.id === createShiftDto.id) {
        return existingOpenShift;
      }
      // Otherwise, it's a conflict
      throw new BadRequestException('User already has an open shift');
    }

    const shift = this.shiftsRepository.create({
      id: createShiftDto.id, // Optional
      user,
      startTime: createShiftDto.startTime
        ? new Date(createShiftDto.startTime)
        : new Date(),
      startingCash: createShiftDto.startingCash,
      deviceId: createShiftDto.deviceId,
      status: ShiftStatus.OPEN,
    });

    return this.shiftsRepository.save(shift);
  }

  async getOpenShift(userId: string): Promise<Shift | null> {
    return this.shiftsRepository.findOne({
      where: {
        user: { id: userId },
        status: ShiftStatus.OPEN,
      },
    });
  }

  async closeShift(
    userId: string,
    closeShiftDto: CloseShiftDto,
  ): Promise<Shift> {
    let shift: Shift | null;

    if (closeShiftDto.shiftId) {
      shift = await this.shiftsRepository.findOne({
        where: { id: closeShiftDto.shiftId, user: { id: userId } },
      });
    } else {
      shift = await this.getOpenShift(userId);
    }

    if (!shift) {
      throw new NotFoundException('Shift not found');
    }

    if (shift.status === ShiftStatus.CLOSED) {
      // Idempotency: already closed
      return shift;
    }

    // Calculate totals
    const endTime = new Date();

    // Get all orders for this shift
    const orders = await this.ordersRepository.find({
      where: { shiftId: shift.id },
    });

    let totalCashSales = 0;
    let totalCardSales = 0;

    for (const order of orders) {
      if (order.paymentStatus === PaymentStatus.PAID) {
        if (order.paymentMethod === PaymentMethod.CASH) {
          totalCashSales += Number(order.totalAmount);
        } else if (order.paymentMethod === PaymentMethod.CARD) {
          totalCardSales += Number(order.totalAmount);
        }
      }
    }

    // Get Cash Transactions
    const transactions = await this.cashTransactionsRepository.find({
      where: { shift: { id: shift.id } },
    });

    let totalCashIn = 0;
    let totalCashOut = 0;

    for (const tx of transactions) {
      if (tx.type === TransactionType.IN) {
        totalCashIn += Number(tx.amount);
      } else {
        totalCashOut += Number(tx.amount);
      }
    }

    const expectedCash =
      Number(shift.startingCash) + totalCashSales + totalCashIn - totalCashOut;
    const difference = Number(closeShiftDto.endingCash) - expectedCash;

    shift.endTime = endTime;
    shift.endingCash = closeShiftDto.endingCash;
    shift.totalCashSales = totalCashSales;
    shift.totalCardSales = totalCardSales;
    shift.totalCashIn = totalCashIn;
    shift.totalCashOut = totalCashOut;
    shift.expectedCash = expectedCash;
    shift.difference = difference;
    shift.status = ShiftStatus.CLOSED;
    shift.notes = closeShiftDto.notes ?? '';

    return this.shiftsRepository.save(shift);
  }

  async addCashTransaction(
    userId: string,
    dto: CreateCashTransactionDto,
  ): Promise<CashTransaction> {
    let shift: Shift | null;
    if (dto.shiftId) {
      shift = await this.shiftsRepository.findOne({
        where: { id: dto.shiftId, user: { id: userId } },
      });
    } else {
      shift = await this.getOpenShift(userId);
    }

    if (!shift) {
      throw new NotFoundException('No open shift found for this user');
    }

    const transaction = this.cashTransactionsRepository.create({
      shift,
      type: dto.type,
      amount: dto.amount,
      reason: dto.reason,
    });

    return this.cashTransactionsRepository.save(transaction);
  }

  async getShiftDetails(id: string): Promise<Shift> {
    const shift = await this.shiftsRepository.findOne({
      where: { id },
      relations: ['user', 'cashTransactions'],
    });

    if (!shift) {
      throw new NotFoundException('Shift not found');
    }

    return shift;
  }
}
