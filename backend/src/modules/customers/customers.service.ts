import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, EntityManager } from 'typeorm';
import { Customer } from './customer.entity';
import { LoyaltyTransaction, LoyaltyTransactionType } from './loyalty-transaction.entity';

@Injectable()
export class CustomersService {
  constructor(
    @InjectRepository(Customer)
    private customersRepository: Repository<Customer>,
    @InjectRepository(LoyaltyTransaction)
    private loyaltyTransactionRepository: Repository<LoyaltyTransaction>,
  ) {}

  async findAll(query?: string) {
    if (query) {
      return this.customersRepository
        .createQueryBuilder('customer')
        .where('customer.name LIKE :query OR customer.phoneNumber LIKE :query', { query: `%${query}%` })
        .getMany();
    }
    return this.customersRepository.find();
  }

  findOne(id: string) {
    return this.customersRepository.findOne({ where: { id } });
  }

  async findByPhone(phoneNumber: string) {
    return this.customersRepository.findOne({ where: { phoneNumber } });
  }

  create(data: Partial<Customer>) {
    const customer = this.customersRepository.create(data);
    return this.customersRepository.save(customer);
  }

  async update(id: string, data: Partial<Customer>) {
    await this.customersRepository.update(id, data);
    return this.findOne(id);
  }

  async addPoints(id: string, points: number, type: LoyaltyTransactionType = LoyaltyTransactionType.EARN, orderId?: string, manager?: EntityManager) {
    if (points === 0) return;

    const repo = manager ? manager.getRepository(Customer) : this.customersRepository;
    const transactionRepo = manager ? manager.getRepository(LoyaltyTransaction) : this.loyaltyTransactionRepository;

    const customer = await repo.findOne({ where: { id } });
    if (customer) {
      customer.loyaltyPoints += points;
      
      // Update Tier
      if (customer.loyaltyPoints >= 5000) customer.tier = 'PLATINUM';
      else if (customer.loyaltyPoints >= 2000) customer.tier = 'GOLD';
      else if (customer.loyaltyPoints >= 500) customer.tier = 'SILVER';
      else customer.tier = 'BRONZE';

      await repo.save(customer);

      const transaction = transactionRepo.create({
        customerId: id,
        points,
        type,
        orderId,
        description: `Points ${points > 0 ? 'earned' : 'deducted'} from order ${orderId || 'manual'}`,
      });
      await transactionRepo.save(transaction);
    }
  }

  async getLoyaltyHistory(customerId: string) {
    return this.loyaltyTransactionRepository.find({
      where: { customerId },
      order: { createdAt: 'DESC' },
    });
  }
}
