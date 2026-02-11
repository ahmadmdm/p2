import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, LessThanOrEqual, Raw } from 'typeorm';
import { Order, PaymentStatus } from '../orders/order.entity';
import { OrderItem } from '../orders/order-item.entity';
import { InventoryItem } from '../inventory/inventory-item.entity';
import * as ExcelJS from 'exceljs';
import PDFDocument from 'pdfkit';

@Injectable()
export class ReportsService {
  constructor(
    @InjectRepository(Order)
    private ordersRepo: Repository<Order>,
    @InjectRepository(OrderItem)
    private orderItemsRepo: Repository<OrderItem>,
    @InjectRepository(InventoryItem)
    private inventoryRepo: Repository<InventoryItem>,
  ) {}

  async getSalesByDateRange(startDate: Date, endDate: Date) {
    return this.ordersRepo.find({
      where: {
        createdAt: Between(startDate, endDate),
        paymentStatus: PaymentStatus.PAID,
      },
      relations: ['items', 'items.product'],
      order: { createdAt: 'DESC' },
    });
  }

  async generateSalesExcel(startDate: Date, endDate: Date): Promise<Buffer> {
    const orders = await this.getSalesByDateRange(startDate, endDate);
    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet('Sales Report');

    sheet.columns = [
      { header: 'Order ID', key: 'id', width: 30 },
      { header: 'Date', key: 'date', width: 20 },
      { header: 'Total Amount', key: 'total', width: 15 },
      { header: 'Payment Method', key: 'payment', width: 15 },
      { header: 'Items', key: 'items', width: 50 },
    ];

    orders.forEach(order => {
      const itemsStr = order.items.map(i => `${i.product.name['en'] || i.product.name} (x${i.quantity})`).join(', ');
      sheet.addRow({
        id: order.id,
        date: order.createdAt.toISOString(),
        total: order.totalAmount,
        payment: order.paymentMethod,
        items: itemsStr,
      });
    });

    // Add summary row
    const totalSales = orders.reduce((sum, o) => sum + Number(o.totalAmount), 0);
    sheet.addRow({});
    sheet.addRow({ date: 'TOTAL', total: totalSales });

    return (await workbook.xlsx.writeBuffer()) as unknown as Buffer;
  }

  async generateSalesPdf(startDate: Date, endDate: Date): Promise<Buffer> {
    const orders = await this.getSalesByDateRange(startDate, endDate);
    
    return new Promise((resolve) => {
      const doc = new PDFDocument();
      const buffers: Buffer[] = [];

      doc.on('data', buffers.push.bind(buffers));
      doc.on('end', () => {
        resolve(Buffer.concat(buffers));
      });

      doc.fontSize(20).text('Sales Report', { align: 'center' });
      doc.moveDown();
      doc.fontSize(12).text(`From: ${startDate.toISOString().split('T')[0]} To: ${endDate.toISOString().split('T')[0]}`);
      doc.moveDown();

      let totalSales = 0;

      orders.forEach((order, index) => {
        doc.fontSize(10).text(`Order #${order.id.substring(0, 8)} - ${order.createdAt.toISOString().split('T')[0]} - $${order.totalAmount}`);
        // doc.text(`Items: ${order.items.map(i => i.product.name['en']).join(', ')}`, { color: 'gray' });
        totalSales += Number(order.totalAmount);
        doc.moveDown(0.5);
      });

      doc.moveDown();
      doc.fontSize(14).font('Helvetica-Bold').text(`Total Sales: $${totalSales.toFixed(2)}`);

      doc.end();
    });
  }

  async getLowStockAlerts() {
    // Find items where quantity <= minLevel
    // Note: TypeORM doesn't support "where column <= other_column" easily in 'find' options without Raw or QueryBuilder
    // Let's use QueryBuilder
    return this.inventoryRepo
      .createQueryBuilder('item')
      .leftJoinAndSelect('item.ingredient', 'ingredient')
      .where('item.quantity <= item.minLevel')
      .getMany();
  }

  async getDailySales() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const orders = await this.ordersRepo.find({
      where: {
        createdAt: Between(today, tomorrow),
        paymentStatus: PaymentStatus.PAID,
      },
    });

    const totalSales = orders.reduce((sum, order) => sum + Number(order.totalAmount), 0);
    const orderCount = orders.length;

    return {
      date: today.toISOString().split('T')[0],
      totalSales,
      orderCount,
    };
  }

  async getTopProducts() {
    // Basic aggregation using QueryBuilder
    return this.orderItemsRepo
      .createQueryBuilder('item')
      .leftJoinAndSelect('item.product', 'product')
      .select('product.name', 'productName')
      .addSelect('SUM(item.quantity)', 'totalSold')
      .groupBy('product.id')
      .addGroupBy('product.name')
      .orderBy('SUM(item.quantity)', 'DESC')
      .limit(5)
      .getRawMany();
  }

  async getSalesByCategory() {
    return this.orderItemsRepo
      .createQueryBuilder('item')
      .leftJoin('item.product', 'product')
      .leftJoin('product.category', 'category')
      .select('category.name', 'categoryName')
      .addSelect('SUM(item.price * item.quantity)', 'totalSales')
      .groupBy('category.id')
      .addGroupBy('category.name')
      .orderBy('totalSales', 'DESC')
      .getRawMany();
  }
}
