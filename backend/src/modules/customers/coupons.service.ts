import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Coupon, CouponType } from './coupon.entity';

@Injectable()
export class CouponsService {
  constructor(
    @InjectRepository(Coupon)
    private couponsRepository: Repository<Coupon>,
  ) {}

  async create(data: Partial<Coupon>): Promise<Coupon> {
    const coupon = this.couponsRepository.create(data);
    return this.couponsRepository.save(coupon);
  }

  async findAll(): Promise<Coupon[]> {
    return this.couponsRepository.find();
  }

  async validateCoupon(code: string, orderTotal: number): Promise<Coupon> {
    const coupon = await this.couponsRepository.findOneBy({ code });
    if (!coupon) {
      throw new NotFoundException('Coupon not found');
    }

    if (!coupon.isActive) {
      throw new BadRequestException('Coupon is inactive');
    }

    if (coupon.expiresAt && new Date() > coupon.expiresAt) {
      throw new BadRequestException('Coupon has expired');
    }

    if (coupon.maxUses && coupon.usedCount >= coupon.maxUses) {
      throw new BadRequestException('Coupon usage limit reached');
    }

    if (orderTotal < coupon.minOrderAmount) {
      throw new BadRequestException(
        `Minimum order amount is ${coupon.minOrderAmount}`,
      );
    }

    return coupon;
  }

  async incrementUsage(id: string) {
    await this.couponsRepository.increment({ id }, 'usedCount', 1);
  }
}
