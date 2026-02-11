
const API_URL = 'http://localhost:3001';

async function main() {
  try {
    console.log('--- Starting Loyalty Flow Verification ---');

    // 1. Login/Register with unique user
    console.log('1. Logging in/Registering...');
    let token = '';
    const email = `admin_${Date.now()}@test.com`;
    const password = 'password';
    
    // Register first to ensure fresh user
    console.log(`Registering user: ${email}...`);
    const regRes = await fetch(`${API_URL}/auth/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password, name: 'Admin User', role: 'admin' }),
    });
    
    if (!regRes.ok && regRes.status !== 409) { // 409 = conflict/exists
        console.error('Registration failed:', await regRes.text());
    }

    // Login
    const loginRes = await fetch(`${API_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
    });
    
    if (loginRes.ok) {
        const data = await loginRes.json();
        if (data.access_token) {
             token = data.access_token;
        } else {
             console.error('Login response missing token:', data);
             process.exit(1);
        }
    } else {
        console.error('Login failed:', await loginRes.text());
        process.exit(1);
    }
    console.log('Logged in. Token acquired.');

    const headers = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
    };

    // 2. Get a Table
    console.log('2. Getting a Table...');
    let tableId = '';
    const tablesRes = await fetch(`${API_URL}/tables`, { headers });
    const tables = await tablesRes.json();
    if (Array.isArray(tables) && tables.length > 0) {
      tableId = tables[0].id;
    } else {
      const createTableRes = await fetch(`${API_URL}/tables`, {
        method: 'POST',
        headers,
        body: JSON.stringify({ tableNumber: `T${Date.now()}`, capacity: 4 }),
      });
      const table = await createTableRes.json();
      tableId = table.id;
    }
    console.log(`Table ID: ${tableId}`);

    // 3. Get/Create Product
    console.log('3. Getting/Creating Product...');
    let productId = '';
    
    // Get Categories
    const catRes = await fetch(`${API_URL}/catalog/categories`, { headers });
    let categories = await catRes.json();
    let catId = '';
    if (Array.isArray(categories) && categories.length > 0) {
        catId = categories[0].id;
    } else {
        const newCat = await fetch(`${API_URL}/catalog/categories`, {
            method: 'POST',
            headers,
            body: JSON.stringify({ name: { en: 'General', ar: 'عام' } }) // Updated payload structure if needed, or use nameEn/nameAr
        });
        // Check payload structure in controller. catalog.controller.ts uses CreateCategoryDto?
        // Let's assume nameEn/nameAr based on previous code.
        if (!newCat.ok) {
            // Try nameEn
             const newCat2 = await fetch(`${API_URL}/catalog/categories`, {
                method: 'POST',
                headers,
                body: JSON.stringify({ nameEn: 'General', nameAr: 'عام' })
            });
            const c = await newCat2.json();
            catId = c.id;
        } else {
            const c = await newCat.json();
            catId = c.id;
        }
    }
    console.log(`Category ID: ${catId}`);

    // Create a specific product for testing to avoid using random existing one
    const createProdRes = await fetch(`${API_URL}/catalog/categories/${catId}/products`, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        name: { en: `Loyalty Item ${Date.now()}`, ar: 'Loyalty Item' },
        price: 100,
        isAvailable: true
      }),
    });
    
    if (createProdRes.ok) {
        const product = await createProdRes.json();
        productId = product.id;
    } else {
        console.error('Failed to create product:', await createProdRes.text());
        // Fallback to find existing
        const productsRes = await fetch(`${API_URL}/catalog/products`, { headers });
        const products = await productsRes.json();
        if (products.length > 0) productId = products[0].id;
    }
    console.log(`Product ID: ${productId}`);
    
    if (!productId) {
        throw new Error('No product available');
    }

    // 4. Create Customer
    console.log('4. Creating Customer...');
    const customerRes = await fetch(`${API_URL}/customers`, {
      method: 'POST',
      headers,
      body: JSON.stringify({ name: `Loyalty Test User ${Date.now()}`, phoneNumber: `${Date.now()}` }),
    });
    const customer = await customerRes.json();
    const customerId = customer.id;
    console.log(`Customer Created: ${customerId}, Points: ${customer.loyaltyPoints}`);

    // 5. Place Order (CASH) - Should earn points
    console.log('5. Placing Order (CASH)...');
    const order1Res = await fetch(`${API_URL}/orders`, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        tableId,
        customerId,
        paymentMethod: 'CASH',
        items: [{ productId, quantity: 1 }] // Total 100 -> 10 points
      }),
    });
    
    if (!order1Res.ok) {
        console.error('Order 1 failed:', await order1Res.text());
        process.exit(1);
    }
    const order1 = await order1Res.json();
    console.log(`Order 1 placed: ${order1.id}, Total: ${order1.totalAmount}`);

    // Check points
    const custRes1 = await fetch(`${API_URL}/customers/${customerId}`, { headers });
    const cust1 = await custRes1.json();
    console.log(`Customer Points after Order 1: ${cust1.loyaltyPoints}`);
    if (cust1.loyaltyPoints !== 10) {
        console.warn('WARNING: Expected 10 points!');
    } else {
        console.log('SUCCESS: Earned 10 points.');
    }

    // 6. Place Order 2 (CASH) - Earn more points
    console.log('6. Placing Order 2 (CASH)...');
    const order2Res = await fetch(`${API_URL}/orders`, {
        method: 'POST',
        headers,
        body: JSON.stringify({
          tableId,
          customerId,
          paymentMethod: 'CASH',
          items: [{ productId, quantity: 1 }] // Total 100 -> +10 points -> Total 20
        }),
      });
    const order2 = await order2Res.json();
    
    // Check points
    const custRes2 = await fetch(`${API_URL}/customers/${customerId}`, { headers });
    const cust2 = await custRes2.json();
    console.log(`Customer Points after Order 2: ${cust2.loyaltyPoints}`);
    if (cust2.loyaltyPoints !== 20) {
        console.warn('WARNING: Expected 20 points!');
    } else {
        console.log('SUCCESS: Earned 10 more points. Total 20.');
    }

    // 7. Place Order 3 (LOYALTY) - Redeem points
    console.log('7. Creating Cheap Item for Redemption...');
    const cheapProdRes = await fetch(`${API_URL}/catalog/categories/${catId}/products`, {
        method: 'POST',
        headers,
        body: JSON.stringify({
          name: { en: 'Cheap Item', ar: 'Cheap Item' },
          price: 1, // 1.00 -> 10 points
          isAvailable: true
        }),
    });
    
    let cheapProductId = '';
    if (cheapProdRes.ok) {
        const cheapProduct = await cheapProdRes.json();
        cheapProductId = cheapProduct.id;
    } else {
         // Maybe it already exists? Or use productId if it was cheap?
         // Just use productId but quantity 0.1? No quantity is integer usually.
         // Let's assume we can create it.
         console.error('Failed to create cheap product', await cheapProdRes.text());
         process.exit(1);
    }
    
    console.log('8. Placing Order 3 (LOYALTY)...');
    const order3Res = await fetch(`${API_URL}/orders`, {
        method: 'POST',
        headers,
        body: JSON.stringify({
          tableId,
          customerId,
          paymentMethod: 'LOYALTY',
          items: [{ productId: cheapProductId, quantity: 1 }] // Total 1 -> 10 points needed
        }),
    });

    if (!order3Res.ok) {
        console.error('Order 3 failed:', await order3Res.text());
        process.exit(1);
    }
    const order3 = await order3Res.json();
    console.log(`Order 3 placed: ${order3.id}, Payment: ${order3.paymentMethod}`);

    // Check points
    const custRes3 = await fetch(`${API_URL}/customers/${customerId}`, { headers });
    const cust3 = await custRes3.json();
    console.log(`Customer Points after Order 3: ${cust3.loyaltyPoints}`);
    
    // Started with 20, used 10 -> Should be 10.
    if (cust3.loyaltyPoints !== 10) {
        console.warn('WARNING: Expected 10 points!');
    } else {
        console.log('SUCCESS: Redeemed 10 points. Balance 10.');
    }

    // 9. Check History
    console.log('9. Checking Loyalty History...');
    const historyRes = await fetch(`${API_URL}/customers/${customerId}/loyalty-history`, { headers });
    const history = await historyRes.json();
    console.log(`History Entries: ${history.length}`);
    history.forEach((h: any) => console.log(` - ${h.type}: ${h.points} (${h.description})`));

    if (history.length >= 3) {
        console.log('SUCCESS: History looks correct.');
    } else {
        console.warn('WARNING: Missing history entries.');
    }

    console.log('--- Verification Complete ---');

  } catch (err) {
    console.error('Script failed:', err);
  }
}

main();
