import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { CatalogService } from './modules/catalog/catalog.service';
import { TablesService } from './modules/tables/tables.service';
import { AuthService } from './modules/auth/auth.service';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  
  const catalogService = app.get(CatalogService);
  const tablesService = app.get(TablesService);
  const authService = app.get(AuthService);

  console.log('Seeding data...');

  // 1. Create Admin User (if Auth logic allows registration via seed, or we just insert directly)
  // Since AuthService.register usually hashes password, we can use it.
  try {
    await authService.register({
      email: 'admin@pos.com', 
      password: 'admin123', 
      name: 'Admin User',
      role: 'ADMIN'
    });
    console.log('Admin user created');
  } catch (e) {
    console.log('Admin user likely exists');
  }

  // 2. Create Categories
  const categories = ['Starters', 'Mains', 'Desserts', 'Drinks'];
  const createdCats = [];
  
  for (const name of categories) {
    try {
      const cat = await catalogService.createCategory({ 
        name: { en: name, ar: name }, // Simple mapping for now
        sortOrder: categories.indexOf(name) 
      });
      createdCats.push(cat);
      console.log(`Category ${name} created`);
    } catch (e) {
      console.log(`Category ${name} likely exists`);
      // We need to fetch it if it exists to link products
      const all = await catalogService.findAllCategories();
      const existing = all.find(c => c.name.en === name);
      if (existing) createdCats.push(existing);
    }
  }

  // 3. Create Products
  const products = [
    { name: 'Caesar Salad', price: 12.50, cat: 'Starters' },
    { name: 'Soup of the Day', price: 8.00, cat: 'Starters' },
    { name: 'Grilled Chicken', price: 25.00, cat: 'Mains' },
    { name: 'Beef Steak', price: 35.00, cat: 'Mains' },
    { name: 'Cheesecake', price: 9.00, cat: 'Desserts' },
    { name: 'Cola', price: 3.00, cat: 'Drinks' },
    { name: 'Orange Juice', price: 5.00, cat: 'Drinks' },
  ];

  for (const p of products) {
    const cat = createdCats.find(c => c.name.en === p.cat);
    if (cat) {
      try {
        await catalogService.createProduct(cat.id, {
          name: { en: p.name, ar: p.name },
          price: p.price,
          isAvailable: true,
        });
        console.log(`Product ${p.name} created`);
      } catch (e) {
        console.log(`Product ${p.name} likely exists`);
      }
    }
  }

  // 4. Create Tables
  const tables = ['T1', 'T2', 'T3', 'T4', 'P1', 'P2'];
  for (const t of tables) {
    try {
      await tablesService.create({
        tableNumber: t,
        section: t.startsWith('T') ? 'Main Hall' : 'Patio',
        capacity: 4
      });
      console.log(`Table ${t} created`);
    } catch (e) {
      console.log(`Table ${t} likely exists`);
    }
  }

  console.log('Seeding complete!');
  await app.close();
}

bootstrap();
